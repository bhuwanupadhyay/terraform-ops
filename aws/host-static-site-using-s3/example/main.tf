terraform {
  required_version = ">= 0.13.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "s3" {}
}

variable "region" {
  default = "us-east-1"
}

provider "aws" {
  region = var.region
}

provider "aws" {
  alias  = "main"
  region = var.region
}

module "host-static-site-using-s3" {
  source      = "../"
  domain_name = "my-static-site.com"
  region      = var.region
  tags = {
    Env = "Prod"
  }
}
