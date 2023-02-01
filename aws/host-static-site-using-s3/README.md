# Host static site using S3

This module creates an S3 bucket and configures it to host a static website.

## Requirements

* Route53 Hosted Zone for the domain name.

## Usage

```terraform
module "host-static-site-using-s3" {
  source      = "git::https://github.com/bhuwanupadhyay/terraform-ops.git//aws/host-static-site-using-s3"
  domain_name = "my-static-site.com"
  region      = var.region
  tags        = {
    Env = "Prod"
  }
}
```

For complete example, see [example](example).
