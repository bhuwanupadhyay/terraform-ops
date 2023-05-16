terraform {
  required_version = ">= 0.13.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

variable "region" {
  default = "us-east-1"
}

provider "aws" {
  region = var.region
}

module "this" {
  source            = "../"
  launchpad_name    = "test"
  aws_instance_ami  = "ami-0d8f6eb4f641ef691"
  aws_instance_type = "t2.micro"
  aws_instance_user = "ubuntu"
}
