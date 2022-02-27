variable "aws_region" {
  description = "The Region that we will be building the module in"
  type        = string
}

variable "cf_stack_name" {
  description = "Dedicated host CloudFormation stack name. It can include letters (A-Z and a-z), numbers (0-9), and dashes (-)."
  type        = string
  default     = "host-resource-group"
}

variable "host_resource_group_prefix" {
  description = "Prefix used to create ASG Launch template & Host Resource Group license configuration"
  type        = string
  default     = "mac1-"
}
