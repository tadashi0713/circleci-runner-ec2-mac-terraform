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
  description = "Runner auth token.  See docs for how to generate one. https://circleci.com/docs/2.0/runner-installation/#authentication"
  type        = string
}

variable "ami_id" {
  description = "SSM Parameter used to lookup the EC2 Mac1 AMI"
  type        = string
}

variable "host_resource_group_cfn_stack_name" {
  description = "Host Resource Group CFN Stack Created"
  type        = string
}

variable "license_manager_arn" {
  description = "The ARN of the License Configuration named MyDefaultLicense"
  type        = string
}

#-------------------------------------------------------------------------------
# OPTIONAL VARS
# Default values supplied, but you should still review each one.
#-------------------------------------------------------------------------------

variable "number_of_instances" {
  description = "Desired Capacity of EC2 Mac1 instances in ASG"
  type        = number
  default     = 1
}

variable "min_num_instances" {
  description = "Min number of EC2 Mac1 instances in ASG"
  type        = number
  default     = 1
}

variable "max_num_instances" {
  description = "Max number of EC2 Mac1 instances in ASG"
  type        = number
  default     = 2
}

variable "number_of_instances_scale" {
  description = "Desired Capacity of EC2 Mac1 instances in ASG when scalling"
  type        = number
  default     = 2
}

variable "min_num_instances_scale" {
  description = "Min number of EC2 Mac1 instances in ASG when scalling"
  type        = number
  default     = 2
}

variable "max_num_instances_scale" {
  description = "Max number of EC2 Mac1 instances in ASG when scalling"
  type        = number
  default     = 3
}

variable "scale_up_cron" {
  description = "Unix cron syntax format of when to scale up"
  type        = string
  default     = "0 8 * * MON-FRI"
}

variable "scale_down_cron" {
  description = "Unix cron syntax format of when to scale down"
  type        = string
  default     = "0 20 * * *"
}

variable "autoscaling_schedule_time_zone" {
  description = "Time Zone of Autoscalling Schedule"
  type        = string
  default     = "UTC"
}

variable "worker_prefix" {
  description = "Prefix used to create ASG Launch template & Host Resource Group license configuration"
  type        = string
  default     = "circleci-runner-mac"
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
  default     = []
}

variable "mac_ebs_volume_size" {
  description = "EC2 Mac1 EBS volume size"
  type        = number
  default     = 200
}
