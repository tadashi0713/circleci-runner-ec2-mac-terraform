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

* You can customize AMI to install other softwares needed for mobile development(Flutter SDK, etc.)
* You can customize storage of EC2 Mac instances(AWS EBS)
* After AWS provide M1 EC2 Mac(`mac2.metal`), this runner also can suppport(WIP, after M1 EC2 Mac become GA)
* Can support [CircleCI Server](https://circleci.com/docs/2.0/server-3-overview/)(WIP)

## Work in progress

* Customize for [CircleCI Server](https://circleci.com/docs/2.0/server-3-overview/)
* [Enable SSH debug](https://circleci.com/docs/2.0/runner-overview/#debugging-with-ssh)
* Support other autoscalling solutions
* Support M1 EC2 Mac(`mac2.metal`, after M1 EC2 Mac become GA)
* Use Ansible instead of [install.sh]("./images/install.sh")

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

Please also refer to this document provided by AWS.

[Building Amazon Machine Images (AMIs) for EC2 Mac instances with Packer](https://aws.amazon.com/jp/blogs/compute/building-amazon-machine-images-amis-for-ec2-mac-instances-with-packer/)

In order to build/test iOS app in EC2 Mac instances, you have to install Xcode and other softwares since default AMI does not include them.

Since it takes more than 1 hours to install them(especially Xcode), it's needed to create custom AMIs for EC2 Mac instances.

This time, we will create them with Packer.

<img src="./docs/packer.png" width="500px">

In order to build custom AMI using Packer, you will need EC2 Mac instance with Dedicated Host.

First, check whether 

```sh
aws ec2 describe-instance-type-offerings --filters Name=instance-type,Values=mac1.metal Name=location,Values=us-east-2b --location-type availability-zone --region us-east-2
```

```json
{
    "InstanceTypeOfferings": [
        {
            "InstanceType": "mac1.metal",
            "LocationType": "availability-zone",
            "Location": "us-east-2b"
        }
    ]
}
```

If you 

```sh
aws ec2 allocate-hosts --auto-placement on --region us-east-2 --availability-zone us-east-2b --instance-type mac1.metal --quantity 1
```

In 

There are variables to install Xcode, you will need to pass required [variables](./images/variables.pkr.hcl)



`xcode_install_email` and `xcode_install_password` are email/password of Apple Developer Program Account.

In addition to put 

Since Apple Developer Program only allows 2 factor authentication, you cannot authenticate only with email/password.

In order to solve this, you need to create called `FASTLANE_SESSION` using [fastlane spaceauth](https://docs.fastlane.tools/getting-started/ios/authentication/)

```sh
fastlane spaceauth -u user@email.com
```

After you prepare all variables and `FASTLANE_SESSION`, run `packer build`.

```sh
cd images
FASTLANE_SESSION='genrated session by fastlane spaceauth' packer build .
```

It will take more than 1 hour to build AMI.

After packer build complete, you will get custom AMI ID.

```sh
==> Builds finished. The artifacts of successful builds are:
--> amazon-ebs.circleci-runner-ec2-mac-packer: AMIs were created:
us-east-2: ami-hogehoge
```

After you created custom AMI, you need to shutdown any launched instances and release the Dedicated Host.

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
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Providers

No providers.

## Resources

No resources.

## Inputs

No inputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
