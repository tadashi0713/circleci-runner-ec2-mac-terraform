variable "subnet_id" {
  type = string
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "ami_prefix" {
  type    = string
  default = "circleci-mac-runner"
}

variable "root_volume_size_gb" {
  type    = number
  default = 150
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

variable "xcode_version" {
  type    = string
  default = "13.2.1"
}

variable "ruby_version" {
  type    = string
  default = "3.1.1"
}
