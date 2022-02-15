resource "random_pet" "host_resource_group" {
  length    = 2
  prefix    = join("", [var.host_resource_group_prefix, var.cf_stack_name])
  separator = "-"
}

resource "aws_licensemanager_license_configuration"  "license_config"{  
  name                     = "MyRequiredLicense"
  description              = "Pass through configuration for Host Resource Group"
  license_count            = 32
  license_count_hard_limit = false
  license_counting_type    = "Core"
}

resource "aws_cloudformation_stack" "mac1_host_resource_group" {
  name = random_pet.host_resource_group.id
  #tags = var.tags

  template_body = <<STACK
{
    "Resources" : {
        "HostResourceGroup": {
            "Type": "AWS::ResourceGroups::Group",
            "Properties": {
                "Name": "${random_pet.host_resource_group.id}",
                "Configuration": [
                    {
                        "Type": "AWS::EC2::HostManagement",
                        "Parameters": [
                            {
                                "Name": "allowed-host-based-license-configurations",
                                "Values": [
                                    "${aws_licensemanager_license_configuration.license_config.arn}"
                                ]
                            },
                            {
                                "Name": "allowed-host-families",
                                "Values": [
                                    "mac1"
                                ]
                            },
                            {
                                "Name": "auto-allocate-host",
                                "Values": [
                                    "true"
                                ]
                            },
                            {
                                "Name": "auto-release-host",
                                "Values": [
                                    "true"
                                ]
                            }
                        ]
                    },
                    {
                        "Type": "AWS::ResourceGroups::Generic",
                        "Parameters": [
                            {
                                "Name": "allowed-resource-types",
                                "Values": [
                                    "AWS::EC2::Host"
                                ]
                            },
                            {
                                "Name": "deletion-protection",
                                "Values": [
                                    "UNLESS_EMPTY"
                                ]
                            }
                        ]
                    }
                ]
            }
        }
    },
    "Outputs" : {
        "ResourceGroupArn" : {
            "Description": "ResourceGroup Arn",
            "Value" : { "Fn::GetAtt" : ["HostResourceGroup", "Arn"] },
            "Export" : {
              "Name": "${random_pet.host_resource_group.id}"
            }
        }
    }
}
STACK
}

output host_resource_group_id {
    value = random_pet.host_resource_group.id
    description = "To be put into subsequent stack's tfvars"
}

output "license_manager_arn" {
    value = aws_licensemanager_license_configuration.license_config.arn
    description = "To be put into subsequent stack's tfvars"
}

// resource "aws_ec2_host" "mac" {
//   instance_type     = "mac1.metal"
//   availability_zone = var.aws_availability_zone
//   auto_placement    = "on"

//   tags = {
//     Name = "Tadashi Terraform Mac"
//   }
// }

// resource "aws_ec2_tag" "mac" {
//   resource_id = aws_ec2_host.mac.id
//   key         = "Name"
//   value       = "Tadashi Terraform Mac"
// }

// resource "aws_instance" "mac" {
//   ami           = data.aws_ami.mac.id
//   instance_type = "mac1.metal"
//   host_id       = aws_ec2_host.mac.id
//   subnet_id     = var.subnet_id # Subnet ID in the same AZ as the dedicated host
//   user_data = base64encode(
//     templatefile(
//       "${path.module}/userdata/runner_install.sh.tpl",
//       {
//         auth_token  = "Hello, this is script"
//       }
//     )
//   )

//   tags = {
//     Name = "Tadashi Terraform Mac"
//   }
// }

// data "aws_ami" "mac" {
//   most_recent = true

//   filter {
//     name   = "name"
//     values = ["amzn-ec2-macos-11.6*"]
//   }

//   filter {
//     name   = "virtualization-type"
//     values = ["hvm"]
//   }

//   owners = ["amazon"]
// }

// output "mac_ami" {
//   value = data.aws_ami.mac.id
// }

// output "dedicated-host" {
//   value = aws_ec2_host.mac.id
// }
