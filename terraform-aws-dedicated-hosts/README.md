<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.2.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudformation_stack.mac1_host_resource_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudformation_stack) | resource |
| [aws_licensemanager_license_configuration.license_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/licensemanager_license_configuration) | resource |
| [random_pet.host_resource_group](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The Region that we will be building the module in | `string` | n/a | yes |
| <a name="input_cf_stack_name"></a> [cf\_stack\_name](#input\_cf\_stack\_name) | Dedicated host CloudFormation stack name. It can include letters (A-Z and a-z), numbers (0-9), and dashes (-). | `string` | `"host-resource-group"` | no |
| <a name="input_host_resource_group_prefix"></a> [host\_resource\_group\_prefix](#input\_host\_resource\_group\_prefix) | Prefix used to create ASG Launch template & Host Resource Group license configuration | `string` | `"mac1-"` | no |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
