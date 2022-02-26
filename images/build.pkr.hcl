build {
  sources = ["source.amazon-ebs.circleci-runner-ec2-mac-packer"]
  # resize the partition to use all the space available on the EBS volume
  provisioner "shell" {
    inline = [
      "PDISK=$(diskutil list physical external | head -n1 | cut -d' ' -f1)",
      "APFSCONT=$(diskutil list physical external | grep Apple_APFS | tr -s ' ' | cut -d' ' -f8)",
      "yes | sudo diskutil repairDisk $PDISK",
      "sudo diskutil apfs resizeContainer $APFSCONT 0"
    ]
  }
  # clean the ec2-macos-init history in order to make instance from AMI as it were the first boot
  # see https://github.com/aws/ec2-macos-init#clean for details.
  provisioner "shell" {
    inline = [
      "sudo /usr/local/bin/ec2-macos-init clean --all"
    ]
  }
  # Homebrew
  provisioner "shell" {
    inline = [
      "/usr/local/bin/brew update",
      "/usr/local/bin/brew upgrade",
      "/usr/local/bin/brew install gpg"
    ]
  }
  provisioner "shell" {
    scripts = [
      "./install.sh"
    ]
    environment_vars = [
      "XCODE_INSTALL_USER=${var.xcode_install_email}",
      "XCODE_INSTALL_PASSWORD=${var.xcode_install_password}",
      "FASTLANE_SESSION=${var.fastlane_session}",
      "XCODE_VERSION=${var.xcode_version}",
      "RUBY_VERSION=${var.ruby_version}"
    ]
  }
}
