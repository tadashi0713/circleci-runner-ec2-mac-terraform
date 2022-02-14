module "dedicated-host" {
  source            = "DanielRDias/dedicated-host/aws"
  version           = "0.3.0"
  instance_type     = "mac1.metal"
  availability_zone = var.aws_availability_zone

  tags = {
    Name = "Tadashi Terraform Mac"
  }
}

resource "aws_ec2_tag" "mac" {
  resource_id = module.dedicated-host.dedicated_hosts["HostID"]
  key         = "Name"
  value       = "Tadashi Terraform Mac"
}

resource "aws_instance" "mac" {
  ami           = data.aws_ami.mac.id
  instance_type = "mac1.metal"
  host_id       = module.dedicated-host.dedicated_hosts["HostID"]
  subnet_id     = var.subnet_id # Subnet ID in the same AZ as the dedicated host

  tags = {
    Name = "Tadashi Terraform Mac"
  }
}

data "aws_ami" "mac" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ec2-macos-11.6*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

output "mac_ami" {
  value = data.aws_ami.mac.id
}

output "dedicated-host" {
  value = module.dedicated-host.dedicated_hosts["HostID"]
}
