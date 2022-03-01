<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.2.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.mac_workers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_autoscaling_schedule.scale_down](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_schedule) | resource |
| [aws_autoscaling_schedule.scale_up](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_schedule) | resource |
| [aws_iam_instance_profile.ssm_inst_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.ec2_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ssm_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ec2_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ssm_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_launch_template.mac_workers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_licensemanager_license_configuration.mac_workers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/licensemanager_license_configuration) | resource |
| [aws_security_group.apple_remote_desktop](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_ssm_activation.ssm_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_activation) | resource |
| [random_pet.mac_workers](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [random_string.str_prefix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_cloudformation_export.host_resource_group_arn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudformation_export) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | SSM Parameter used to lookup the EC2 Mac1 AMI | `string` | n/a | yes |
| <a name="input_aws_availability_zone"></a> [aws\_availability\_zone](#input\_aws\_availability\_zone) | AWS Availability Zone in which Runners will be deployed. | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region in which Runners will be deployed. | `string` | n/a | yes |
| <a name="input_host_resource_group_cfn_stack_name"></a> [host\_resource\_group\_cfn\_stack\_name](#input\_host\_resource\_group\_cfn\_stack\_name) | Host Resource Group CFN Stack Created | `string` | n/a | yes |
| <a name="input_license_manager_arn"></a> [license\_manager\_arn](#input\_license\_manager\_arn) | The ARN of the License Configuration named MyDefaultLicense | `string` | n/a | yes |
| <a name="input_runner_auth_token"></a> [runner\_auth\_token](#input\_runner\_auth\_token) | Runner auth token.  See docs for how to generate one. https://circleci.com/docs/2.0/runner-installation/#authentication | `string` | n/a | yes |
| <a name="input_autoscaling_schedule_time_zone"></a> [autoscaling\_schedule\_time\_zone](#input\_autoscaling\_schedule\_time\_zone) | Time Zone of Autoscalling Schedule | `string` | `"UTC"` | no |
| <a name="input_mac_ebs_volume_size"></a> [mac\_ebs\_volume\_size](#input\_mac\_ebs\_volume\_size) | EC2 Mac1 EBS volume size | `number` | `200` | no |
| <a name="input_max_num_instances"></a> [max\_num\_instances](#input\_max\_num\_instances) | Max number of EC2 Mac1 instances in ASG | `number` | `2` | no |
| <a name="input_max_num_instances_scale"></a> [max\_num\_instances\_scale](#input\_max\_num\_instances\_scale) | Max number of EC2 Mac1 instances in ASG when scalling | `number` | `3` | no |
| <a name="input_min_num_instances"></a> [min\_num\_instances](#input\_min\_num\_instances) | Min number of EC2 Mac1 instances in ASG | `number` | `1` | no |
| <a name="input_min_num_instances_scale"></a> [min\_num\_instances\_scale](#input\_min\_num\_instances\_scale) | Min number of EC2 Mac1 instances in ASG when scalling | `number` | `2` | no |
| <a name="input_number_of_instances"></a> [number\_of\_instances](#input\_number\_of\_instances) | Desired Capacity of EC2 Mac1 instances in ASG | `number` | `1` | no |
| <a name="input_number_of_instances_scale"></a> [number\_of\_instances\_scale](#input\_number\_of\_instances\_scale) | Desired Capacity of EC2 Mac1 instances in ASG when scalling | `number` | `2` | no |
| <a name="input_scale_down_cron"></a> [scale\_down\_cron](#input\_scale\_down\_cron) | Unix cron syntax format of when to scale down | `string` | `"0 20 * * *"` | no |
| <a name="input_scale_up_cron"></a> [scale\_up\_cron](#input\_scale\_up\_cron) | Unix cron syntax format of when to scale up | `string` | `"0 8 * * MON-FRI"` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | Security Group Ids used by EC2 Mac1 instances in ASG | `list(string)` | `[]` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet Id for each Availability Zone in ASG | `list(string)` | `[]` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC Id for LB Target Group | `string` | `""` | no |
| <a name="input_worker_prefix"></a> [worker\_prefix](#input\_worker\_prefix) | Prefix used to create ASG Launch template & Host Resource Group license configuration | `string` | `"circleci-runner-mac"` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->