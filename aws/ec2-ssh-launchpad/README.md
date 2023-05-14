# EC2 SSH Launchpad

This module creates an EC2 instance with SSH access.

## Usage

```terraform
module "ec2-ssh-launchpad" {
  source            = "git::https://github.com/bhuwanupadhyay/terraform-ops.git//aws/ec2-ssh-launchpad"
  launchpad_name    = "my-static-site.com"
  aws_instance_ami  = "my-static-site.com"
  aws_instance_type = "my-static-site.com"
  aws_instance_user = "my-static-site.com"
  region            = var.region
  tags              = {
    Env = "Prod"
  }
}
```

For complete example, see [example](example).
