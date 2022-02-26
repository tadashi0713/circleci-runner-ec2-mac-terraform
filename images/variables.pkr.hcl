#-------------------------------------------------------------------------------
# REQUIRED VARS
# Required input values without which the build will not run.
#-------------------------------------------------------------------------------

variable "aws_region" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "xcode_install_email" {
  type = string
}

variable "xcode_install_password" {
  type      = string
  sensitive = true
}

variable "fastlane_session" {
  type      = string
  default   = env("FASTLANE_SESSION")
  sensitive = true
}

#-------------------------------------------------------------------------------
# OPTIONAL VARS
# Default values supplied, but you should still review each one.
#-------------------------------------------------------------------------------

variable "ami_prefix" {
  type    = string
  default = "circleci-mac-runner"
}

variable "root_volume_size_gb" {
  type    = number
  default = 150
}

variable "macos_version" {
  type    = string
  default = "11.6"
}

variable "xcode_version" {
  type    = string
  default = "13.2.1"
}

variable "ruby_version" {
  type    = string
  default = "3.1.1"
}

variable "bundler_version" {
  type    = string
  default = "2.3.8"
}
