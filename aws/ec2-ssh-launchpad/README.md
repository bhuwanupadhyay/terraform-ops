# EC2 SSH Launchpad

This module creates an EC2 instance with SSH access.

## Usage

```terraform
module "ec2-ssh-launchpad" {
  source            = "git::https://github.com/bhuwanupadhyay/terraform-ops.git//aws/ec2-ssh-launchpad"
  launchpad_name    = "test"
  aws_instance_ami  = "ami-0d8f6eb4f641ef691"
  aws_instance_type = "t2.micro"
  aws_instance_user = "ubuntu"
  region            = "us-east-1"
  tags              = {
    Env = "Prod"
  }
}
```

For complete example, see [example](example).
