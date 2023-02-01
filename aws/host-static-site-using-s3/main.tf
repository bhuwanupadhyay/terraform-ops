resource "random_string" "prefix" {
  length  = 8
  special = false
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "s3-cloudfront-website" {
  source              = "riboseinc/s3-cloudfront-website/aws"
  version             = "3.0.1"
  fqdn                = var.domain_name
  ssl_certificate_arn = aws_acm_certificate_validation.cert_validation.certificate_arn
  allowed_ips         = ["0.0.0.0/0"]
  index_document      = "index.html"
  error_document      = "404.html"
  refer_secret        = base64sha512("${random_string.prefix.result}-${var.domain_name}-${random_string.suffix.result}")
  force_destroy       = "true"
  tags                = var.tags

  routing_rule = {
    condition = {
      http_error_code_returned_equals = "401"
    }
    redirect = {
      host_name = var.domain_name
    }
  }

  providers = {
    aws.cloudfront = aws.main
    aws.main       = aws.main
  }
}

resource "aws_route53_record" "web" {
  provider = aws.main
  zone_id  = data.aws_route53_zone.main.zone_id
  name     = var.domain_name
  type     = "A"

  alias {
    name                   = module.s3-cloudfront-website.cf_domain_name
    zone_id                = module.s3-cloudfront-website.cf_hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www-web" {
  provider = aws.main
  zone_id  = data.aws_route53_zone.main.zone_id
  name     = "www.${var.domain_name}"
  type     = "A"

  alias {
    name                   = module.s3-cloudfront-website.cf_domain_name
    zone_id                = module.s3-cloudfront-website.cf_hosted_zone_id
    evaluate_target_health = false
  }
}

resource "null_resource" "z_cf_distribution_id_log" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = "echo '${module.s3-cloudfront-website.cf_distribution_id}' > ${path.cwd}/z_cf_distribution_id.log"
  }
}

output "cf_distribution_id" {
  value = module.s3-cloudfront-website.cf_distribution_id
}
