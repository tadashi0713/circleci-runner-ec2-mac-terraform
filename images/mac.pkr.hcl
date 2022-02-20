variable "ami_name" {
  type    = string
  default = "mac-os-big-sur-ami"
}

variable "subnet_id" {
  type = string
  default = "subnet-0ddaba19b8df56bd8"
}

variable "region" {
  type    = string
  default = "ap-northeast-1"
}

variable "root_volume_size_gb" {
  type = number
  default = 150
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "amazon-ebs" "mac-packer-example" {
  ami_name      = "${var.ami_name}-${local.timestamp}"
  ami_virtualization_type = "hvm"
  ssh_username = "ec2-user"
  ssh_timeout = "2h"
  tenancy = "host"
  ebs_optimized = true
  instance_type = "mac1.metal"
  region        = "${var.region}"
  subnet_id = "${var.subnet_id}"
  ssh_interface = "session_manager"
  aws_polling {
    delay_seconds = 60
    max_attempts = 60
  }
  launch_block_device_mappings {
    device_name = "/dev/sda1"
    volume_size = "${var.root_volume_size_gb}"
    volume_type = "gp3"
    iops = 3000
    throughput = 125
    delete_on_termination = true
  }
  source_ami_filter {
    filters = {
      name                = "amzn-ec2-macos-11.6*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }
  temporary_iam_instance_profile_policy_document {
    Version = "2012-10-17"
    Statement {
      Effect = "Allow"
      Action = [
        "ssm:DescribeAssociation",
        "ssm:GetDeployablePatchSnapshotForInstance",
        "ssm:GetDocument",
        "ssm:DescribeDocument",
        "ssm:GetManifest",
        "ssm:GetParameter",
        "ssm:GetParameters",
        "ssm:ListAssociations",
        "ssm:ListInstanceAssociations",
        "ssm:PutInventory",
        "ssm:PutComplianceItems",
        "ssm:PutConfigurePackageResult",
        "ssm:UpdateAssociationStatus",
        "ssm:UpdateInstanceAssociationStatus",
        "ssm:UpdateInstanceInformation"
      ]
      Resource = ["*"]
    }
    Statement {
      Effect = "Allow"
      Action = [
        "ssmmessages:CreateControlChannel",
        "ssmmessages:CreateDataChannel",
        "ssmmessages:OpenControlChannel",
        "ssmmessages:OpenDataChannel"
      ]
      Resource = ["*"]
    }
    Statement {
      Effect = "Allow"
      Action = [
        "ec2messages:AcknowledgeMessage",
        "ec2messages:DeleteMessage",
        "ec2messages:FailMessage",
        "ec2messages:GetEndpoint",
        "ec2messages:GetMessages",
        "ec2messages:SendReply"
      ]
      Resource = ["*"]
    }
  }
}

build {
  sources = ["source.amazon-ebs.mac-packer-example"]
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
  provisioner "ansible" {
    playbook_file = "./main.yml"
  }
}
