# Build custom AMI using Packer

Please also refer to this document provided by AWS.

[Building Amazon Machine Images (AMIs) for EC2 Mac instances with Packer](https://aws.amazon.com/jp/blogs/compute/building-amazon-machine-images-amis-for-ec2-mac-instances-with-packer/)

In order to build/test iOS app in EC2 Mac instances, you have to install Xcode and other softwares since default AMI does not include them.

Since it takes more than 1 hours to install them(especially Xcode), it's needed to create custom AMIs for EC2 Mac instances.

This time, we will create them with Packer.

<img src="../docs/packer.png" width="500px">

In order to build custom AMI using Packer, you will need EC2 Mac instance with Dedicated Host.

First, in order to determine if a given Region and Availability Zone combination supports the mac1.metal instance type, use the describe-instance-type-offerings command of the AWS CLI.

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

Next, run the following CLI command to allocate a Dedicated Host.

```sh
aws ec2 allocate-hosts --auto-placement on --region us-east-2 --availability-zone us-east-2b --instance-type mac1.metal --quantity 1
```

We use this Dedicated Host to create the AMI via Packer.

There are variables to install Xcode, you will need to pass required [variables](./images/variables.pkr.hcl)

This is sample file of `variables.auto.pkvars.hcl`

```hcl
aws_region             = "us-east-2"
subnet_id              = "subnet-hoge"
xcode_install_email    = "sample@email.com"
xcode_install_password = "password"
```

`xcode_install_email` and `xcode_install_password` are email/password of Apple Developer Program Account.

Since Apple Developer Program only allows 2 factor authentication, you cannot authenticate only with email/password.

In order to solve this, you need to create called `FASTLANE_SESSION` using [fastlane spaceauth](https://docs.fastlane.tools/getting-started/ios/authentication/)

```sh
fastlane spaceauth -u user@email.com
```

After you prepare all variables and `FASTLANE_SESSION`, run `packer build`.

```sh
FASTLANE_SESSION='genrated session by fastlane spaceauth' packer build .
```

It will take more than 1 hour to build AMI.

After packer build complete, you will get custom AMI ID.

```sh
==> Builds finished. The artifacts of successful builds are:
--> amazon-ebs.circleci-runner-ec2-mac-packer: AMIs were created:
us-east-2: ami-hogehoge
```

After you created custom AMI, you need to shutdown any launched instances and release the Dedicated Host in order to prevent incurring costs.