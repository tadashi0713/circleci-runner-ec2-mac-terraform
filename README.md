# CircleCI Runner EC2 Mac Terraform

Terraform plan(and Packer) to deploy autoscaling CircleCI Runner of EC2 Mac instances.

## Features

* You can build and test iOS app in your private AWS VPC, AWS Region
* Better at performance than resource classes which CircleCI Cloud supports(if runners are already provisioned).

| Resource Class            | CPU   | RAM  |
| ------------------------- | ----- | ---- |
| medium                    | 4CPU  | 8GB  |
| large                     | 8CPU  | 16GB |
| x86 EC2 Mac(`mac1.metal`) | 12CPU | 32GB |
| M1 EC2 Mac(`mac2.metal`)  | 12CPU | 16GB |

<img src="./docs/compare.png" width="500px">

* You can customize AMI to install other softwares needed for mobile development using Packer(Flutter SDK, etc.)
* You can customize storage of EC2 Mac instances(AWS EBS)
* After AWS provide M1 EC2 Mac(`mac2.metal`), this runner also can suppport(WIP, after M1 EC2 Mac become GA)
* Can support [CircleCI Server](https://circleci.com/docs/2.0/server-3-overview/)(WIP)

## Work in progress

* Customize for [CircleCI Server](https://circleci.com/docs/2.0/server-3-overview/)
* [Enable SSH debug](https://circleci.com/docs/2.0/runner-overview/#debugging-with-ssh)
* Support other autoscalling solutions
* Support M1 EC2 Mac(`mac2.metal`, after M1 EC2 Mac become GA)
* Use Ansible instead of [install.sh](./images/install.sh)

## Consideration

* EC2 Mac instances are available only as bare metal instances on Dedicated Hosts, with a minimum allocation period of 24 hours before you can release the Dedicated Host.
* Please take special note of the [costs](https://aws.amazon.com/ec2/dedicated-hosts/pricing/) of running EC2 Mac Dedicated hosts for 24 hours
* For EC2 Mac instances, there is a one-to-one mapping between the Dedicated Host and the instance running on this host. This means you are not able to slice a Dedicated Host into multiple instances like you would for Linux and Windows machines.
* For more information about EC2 Mac instances, please refer to [this document](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-mac-instances.html#mac-instance-considerations).

## Getting Started

### Prerequisites

Please install them in your local machine.

* [CircleCI CLI](https://circleci.com/docs/2.0/local-cli/)
* [Terraform](https://www.terraform.io)
* [Packer](https://www.packer.io)
* [AWS CLI with Session Manager plugin](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html)
* [Fastlane](https://docs.fastlane.tools)
* [Apple Developer Program Account](https://developer.apple.com/programs/)

### Build custom AMI using Packer

Please read [this README](./images/README.md).

### Provision autoscalling EC2 Mac runner using Terraform

Please also refer to this document provided by AWS.

[Implementing Auto Scaling for EC2 Mac Instances](https://aws.amazon.com/jp/blogs/compute/implementing-autoscaling-for-ec2-mac-instances/)



<img src="./docs/auto_scalling.png" width="500px">

Before

`terraform.tfvars`


This is sample file of `terraform.tfvars`

```
aws_region            = "us-east-2"
aws_availability_zone = "us-east-2b"
runner_auth_token     = "runner token"
ami_id              = "ami-hogehoge"
vpc_id              = "vpc-fugafuga"
subnet_ids          = ["subnet-hoge"]
```

`runner_auth_token` is 
`ami_id` is custom AMI ID which is created in previous step with Packer.

```
terraform init
terraform plan
terraform apply -auto-approve
```

### Cleaning up

Complete the following steps in order to cleanup resources created by this:

```sh
terraform -chdir=terraform-aws-ec2-mac destroy -auto-approve
```

This will take 10 to 12 minutes. Then, wait 24 hours for the Dedicated Hosts to be capable of being released, and then destroy the next template. We recommend putting a reminder on your calendar to make sure that you don’t forget this step.

```sh
terraform -chdir=terraform-aws-dedicated-hosts destroy -auto-approve
```
