#!/usr/bin/env bash

version=""

binaryName="circleci-launch-agent"
configFileName="launch-agent-config.yaml"
defaultUser="ec2-user"

TIMESTAMP=$(date +"%g%m%d-%H%M%S-%3N")
LAUNCH_AGENT_API_AUTH_TOKEN=${auth_token}
RUNNER_NAME="${runner_name}-$TIMESTAMP"

# Default binary & config installation location
prefix=/System/Volumes/Data/circleci
configDir=/Library/Preferences/com.circleci.runner
launchConfigPath=/Library/LaunchDaemons/com.circleci.runner.plist

# Config file template
defaultConfig=$(cat <<EOF
api:
  auth_token: $LAUNCH_AGENT_API_AUTH_TOKEN
  runner:
    command_prefix: ["sudo", "-niHu", "$defaultUser", "--"]
    working_directory: $prefix/workdir/%s
    cleanup_working_directory: true
  logging:
    file: /Library/Logs/com.circleci.runner.log
EOF
)

defaultLaunchConfig=$(cat <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>Label</key>
        <string>com.circleci.runner</string>

        <key>Program</key>
        <string>$prefix/circleci-launch-agent</string>

        <key>ProgramArguments</key>
        <array>
            <string>circleci-launch-agent</string>
            <string>--config</string>
            <string>/Library/Preferences/com.circleci.runner/launch-agent-config.yaml</string>
            <string>--runner.name</string>
            <string>$RUNNER_NAME</string>
        </array>

        <key>UserName</key>
	      <string>$defaultUser</string>

        <key>RunAtLoad</key>
        <true/>

        <!-- The agent needs to run at all times -->
        <key>KeepAlive</key>
        <true/>

        <!-- This prevents macOS from limiting the resource usage of the agent -->
        <key>ProcessType</key>
        <string>Interactive</string>

        <!-- Increase the frequency of restarting the agent on failure, or post-update -->
        <key>ThrottleInterval</key>
        <integer>3</integer>

        <!-- Wait for 10 minutes for the agent to shut down (the agent itself waits for tasks to complete) -->
        <key>ExitTimeOut</key>
        <integer>600</integer>

        <!-- The agent uses its own logging and rotation to file -->
        <key>StandardOutPath</key>
        <string>/dev/null</string>
        <key>StandardErrorPath</key>
        <string>/dev/null</string>
    </dict>
</plist>
EOF
)

#### Installation Functions ####

get_arch(){
  case "$(uname -m)" in 
    x86_64) echo "amd64" ;;
    aarch64) echo "arm64" ;;
    *) echo "$arch is unsupported for CircleCI Runner on macOS"; exit 1 ;; 
  esac
}

install_dependencies(){
  local deps="shasum git tar gzip"
  local toInstall=""
  for dep in $deps
  do

    if ! command -v "$dep" &> /dev/null; then
      toInstall="$toInstall $dep"
    fi

  if [ ! -z "$toInstall" ]; then
    # only check for homebrew availability if required dependencies are missing
    if ! command -v brew &> /dev/null; then
    echo "Homebrew was not found, installing now"
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    for d in $toInstall
    do
      sudo -u \#"$userId" brew install "$dep"
    done

  fi
  done
}

get_json_field(){
  # $1 expected as resp body
  # $2 expected as field
  echo "$1" | sed 's/,/\n/g' | sed 's/[{|}]//g' | grep "$2" | awk -F "\":" '{ print $2 }' | tr -d '"'
}

download_launch_agent(){
  local attempt=$${2:-"0"}
  local runnerHost=$${LAUNCH_AGENT_API_URL:-"https://runner.circleci.com"}
  local version=$${1:-""}
  local arch="$(get_arch)"

  if [ "$attempt" -ge 3 ]; then
    echo "Unable to download launch agent after $attempt attempts. Please try again later"
    exit 1
  fi

  if [ -z "$version" ]; then
    body="{\"arch\":\"$arch\", \"os\":\"darwin\"}"
  else
    body="{\"arch\":\"$arch\", \"os\":\"darwin\", \"version\":\"$version\"}"
  fi

  dlResp=$(curl -f -X GET -s "$runnerHost/api/v2/launch-agent/download" \
    -d "$body" -H "content-type: application/json" -H "Authorization: Bearer $LAUNCH_AGENT_API_AUTH_TOKEN")
    
  # exit code 22 is a bad or missing token and should not be retried
  exitCode="$?"
  if [ "$exitCode" -ne 0 ]; then
    if [ "$exitCode" -eq 22 ]; then
      echo "Invalid or missing token. Please set LAUNCH_AGENT_API_AUTH_TOKEN to a valid runner token"
      exit 1
    fi
    download_launch_agent "" $((attempt + 1))
  fi

  local checksum="$(get_json_field "$dlResp" "checksum")"
  local dlURL="$(get_json_field "$dlResp" "url")"
  local version="$(get_json_field "$dlResp" "version")"

  # make directory for launch-agent-download
  targetDir="$prefix/darwin/$arch/$version"
  mkdir -p "$targetDir"

  # download the launch agent binary
  curl -s --compressed -L "$dlURL" -o "$targetDir/$binaryName"

  # validate the checksum
  local actualChecksum="$(shasum -a 256 "$targetDir/$binaryName" | awk '{print $1}')"
  if [ "$actualChecksum" == "$checksum" ]; then
    echo "$targetDir/$binaryName"
  else
    download_launch_agent "" $((attempt + 1))
  fi
}

configure_launch_agent(){
  mkdir -p "$configDir"
  echo "$defaultConfig" > "$configDir"/"$configFileName"

  echo "$defaultLaunchConfig" > $launchConfigPath
  chmod 644 $launchConfigPath
  sudo launchctl load $launchConfigPath
}

#### Installation Script ####

# super user permissions are directories in /opt
if [ ! $UID -eq 0 ]; then  
  echo "CircleCI Runner installation must be ran with super user permissions, please rerun with sudo"; 
  exit 1
fi

if [ -z "$LAUNCH_AGENT_API_AUTH_TOKEN" ]; then
  echo "Runner token not found in the \$LAUNCH_AGENT_API_AUTH_TOKEN environment variable, please set and start installation again"
  echo "See https://circleci.com/docs/2.0/runner-installation/ for details"
  exit 1
fi

if ! id -u "$defaultUser" -eq 0; then
  echo "The user $defaultUser was not found, please create the $defaultUser user and start installation again"
  echo "See https://circleci.com/docs/2.0/runner-installation/ for details" 
  exit 1
fi

userId="$(id -u "$defaultUser")"
install_dependencies

# Set up runner directory
mkdir -p "$prefix/workdir"

# Downloading launch agent
echo "Downloading and verifying CircleCI Launch Agent Binary"
binaryPath="$(download_launch_agent)"

# Move the launch agent to the correct directory
cp "$binaryPath" "$prefix/$binaryName"
chmod +x "$prefix/$binaryName"  

echo "Installing the CircleCI Launch Agent"

# Create the configuration
configure_launch_agent

echo "CircleCI Launch Agent Binary succesfully installed"
echo "To validate the CircleCI Launch Agent is running correctly, you can check in log reports for the logs called com.circleci.runner.log"
