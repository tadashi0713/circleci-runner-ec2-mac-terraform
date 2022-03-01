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
* To deploy this solution, a Service Quota Increase must be submitted for Dedicated Hosts, as the default quota is 0. Deploying the solution without this increase will result in failures when provisioning the Dedicated Hosts for the mac1.metal instances.
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

Please also refer to this document provided by AWS.

[Building Amazon Machine Images (AMIs) for EC2 Mac instances with Packer](https://aws.amazon.com/jp/blogs/compute/building-amazon-machine-images-amis-for-ec2-mac-instances-with-packer/)

In order to build/test iOS app in EC2 Mac instances, you have to install Xcode and other softwares since default AMI does not include them.

Since it takes more than 1 hours to install them(especially Xcode), it's needed to create custom AMIs for EC2 Mac instances.

This time, we will create them with Packer.

<img src="./docs/packer.png" width="500px">

Please read [this README](./images/README.md) to create custom AMI using Packer.

### Provision autoscalling EC2 Mac runner using Terraform

Please also refer to this document provided by AWS.

[Implementing Auto Scaling for EC2 Mac Instances](https://aws.amazon.com/jp/blogs/compute/implementing-autoscaling-for-ec2-mac-instances/)

[Official documentation (as of February 2022) states](https://github.com/awsdocs/amazon-ec2-user-guide/blob/master/doc_source/ec2-mac-instances.md): “You cannot use Mac instances with Amazon EC2 Auto Scaling”.

However, with the help of Licence Manager service and Launch Templates, you can set up EC2 Auto Scaling Group for EC2 Mac and leave the automated instance provisioning to the service.

<img src="./docs/auto_scalling.png" width="500px">

First, 

```sh
terraform -chdir=terraform-aws-dedicated-hosts init
terraform -chdir=terraform-aws-dedicated-hosts plan
terraform -chdir=terraform-aws-dedicated-hosts apply -auto-approve
```

For more info about terraform-aws-dedicated-hosts, 

Deploy mac1.metal Auto Scaling Group

```sh
terraform -chdir=terraform-aws-ec2-mac init
terraform -chdir=terraform-aws-ec2-mac plan
terraform -chdir=terraform-aws-ec2-mac apply -auto-approve
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
