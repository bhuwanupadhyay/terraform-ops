# TerraformOps Reusable Modules

This repository contains reusable modules for TerraformOps.

## Modules

### AWS

* [host-static-site-using-s3](aws/host-static-site-using-s3)
* [ec2-ssh-launchpad](aws/host-static-site-using-s3)


## Usage

```terraform
module "<module>" {
  source      = "git::https://github.com/bhuwanupadhyay/terraform-ops.git//<cloud_provider>/<module>"

  ...module inputs...

}
```