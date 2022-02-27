#-------------------------------------------------------------------------------
# REQUIRED VARS
# Required input values without which the build will not run.
#-------------------------------------------------------------------------------

variable "aws_region" {
  description = "AWS Region in which EC2 Mac will be deployed for packer build"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID in which EC2 Mac will be deployed for packer build"
  type        = string
}

variable "xcode_install_email" {
  description = "Email address of Apple Developer Program account in order to install Xcode"
  type        = string
}

variable "xcode_install_password" {
  description = "Password of Apple Developer Program account in order to install Xcode"
  type        = string
  sensitive   = true
}

variable "fastlane_session" {
  description = "FASTLANE_SESSION to pass 2 factor authentication of Apple Developer Program in order to install Xcode"
  type        = string
  default     = env("FASTLANE_SESSION")
  sensitive   = true
}

#-------------------------------------------------------------------------------
# OPTIONAL VARS
# Default values supplied, but you should still review each one.
#-------------------------------------------------------------------------------

variable "ami_prefix" {
  description = "Prefix used for custom AMI"
  type        = string
  default     = "circleci-mac-runner"
}

variable "root_volume_size_gb" {
  description = "Root volume size"
  type        = number
  default     = 150
}

variable "macos_version" {
  description = "macOS version"
  type        = string
  default     = "12.2"
}

variable "xcode_version" {
  description = "Xcode version"
  type        = string
  default     = "13.2.1"
}

variable "ruby_version" {
  description = "Ruby version"
  type        = string
  default     = "3.1.1"
}

variable "bundler_version" {
  description = "Bundler version"
  type        = string
  default     = "2.3.8"
}
