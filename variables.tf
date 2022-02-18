#-------------------------------------------------------------------------------
# REQUIRED VARS
# Required input values without which the plan will not run.
#-------------------------------------------------------------------------------

variable "aws_region" {
  description = "AWS Region in which Runners will be deployed."
  type        = string
}

variable "aws_availability_zone" {
  description = "AWS Availability Zone in which Runners will be deployed."
  type        = string
}

variable "runner_auth_token" {
  description = "Runner auth token.  See docs for how to generate one." #See https://circleci.com/docs/2.0/runner-installation/#authentication
  type        = string
}

variable "number_of_instances" {
  description = "Desired Capacity of EC2 Mac1 instances in ASG"
  type        = number
  default     = 2
}

variable "min_num_instances" {
  description = "Min number of EC2 Mac1 instances in ASG"
  type        = number
  default     = 1
}

variable "max_num_instances" {
  description = "Max number of EC2 Mac1 instances in ASG"
  type        = number
  default     = 3
}

#-------------------------------------------------------------------------------
# OPTIONAL VARS
# Default values supplied, but you should still review each one.
#-------------------------------------------------------------------------------

variable "name" {
  description = "If specified, will set the name of the module to this. If unspecified, a name will be generated"
  type        = string
  default     = ""
}

variable "ami_id" {
  description = "SSM Parameter used to lookup the latest EC2 Mac1 AMI"
  type        = string
  default     = "ami-08c245b8fa8669594"
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

variable "worker_prefix" {
  description = "Prefix used to create ASG Launch template & Host Resource Group license configuration"
  type        = string
  default     = "ec2"
}

variable "tags" {
  description = "(Optional) A list of tags to associate with the CloudFormation stack. Does not propagate to the Dedicated Host."
  type        = map(string)
  default     = null
}

variable "management_subnet" {
  description = "Allow access from management subnet"
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "VPC Id for LB Target Group"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "Subnet Id for each Availability Zone in ASG"
  type        = list(string)
  # Launching a new EC2 instance. (wrt us-east-2a)
  # Status Reason: We currently do not have sufficient mac1.metal capacity in the Availability Zone you requested (us-east-2a). 
  # Our system will be working on provisioning additional capacity. 
  # You can currently get mac1.metal capacity by specifying us-east-2b, us-east-2c in your request. 
  # Launching EC2 instance failed.
  #default     = ["subnet-02fa49fed58e844eb","subnet-08ca30a8af336beee"] # public subnets
  default = [] # testing in us-east-2b / 
}

variable "security_group_ids" {
  description = "Security Group Ids used by EC2 Mac1 instances in ASG"
  type        = list(string)
  default     = ["sg-0d0c462ff917f04e0"]
}

variable "mac_ebs_volume_size" {
  description = "EC2 Mac1 EBS volume size"
  type        = number
  default     = 100
}

variable "key_name" {
  description = "SSH key"
  type        = string
  default     = ""
}
