resource "aws_ec2_host" "mac" {
  instance_type     = "mac1.metal"
  availability_zone = var.aws_availability_zone
  auto_placement    = "on"

  tags = {
    Name = "Tadashi Terraform Mac"
  }
}

resource "aws_ec2_tag" "mac" {
  resource_id = aws_ec2_host.mac.id
  key         = "Name"
  value       = "Tadashi Terraform Mac"
}

resource "aws_instance" "mac" {
  ami           = data.aws_ami.mac.id
  instance_type = "mac1.metal"
  host_id       = aws_ec2_host.mac.id
  subnet_id     = var.subnet_id # Subnet ID in the same AZ as the dedicated host
  user_data = base64encode(
    templatefile(
      "${path.module}/userdata/runner_install.sh.tpl",
      {
        auth_token  = "Hello, this is script"
      }
    )
  )

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
  value = aws_ec2_host.mac.id
}
