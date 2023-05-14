data "aws_region" "available" {}
data "aws_availability_zones" "selected" {}


locals {
  launchpad_name = var.launchpad_name

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.selected.names, 0, 1)
}

# vpc
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.18.1"

  name = local.launchpad_name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "Tier" = "Public"
  }

  private_subnet_tags = {
    "Tier" = "Private"
  }
}

# ssh key
resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kp" {
  key_name   = local.launchpad_name
  public_key = tls_private_key.pk.public_key_openssh
}

resource "local_file" "kp" {
  filename        = "${path.cwd}/build/ssh_${local.launchpad_name}.pem"
  content         = sensitive(tls_private_key.pk.private_key_pem)
  file_permission = "400"
}

# ec2 instance

resource "aws_security_group" "ec2" {
  name   = "${local.launchpad_name}-allow-all-sg"
  vpc_id = module.vpc.vpc_id

  //  SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = local.launchpad_name
  }
}

resource "aws_instance" "ec2" {
  availability_zone = data.aws_availability_zones.selected.names[0]
  ami               = var.aws_instance_ami
  instance_type     = var.aws_instance_type
  key_name          = aws_key_pair.kp.key_name
  subnet_id         = module.vpc.public_subnets[0]

  vpc_security_group_ids = [
    aws_security_group.ec2.id
  ]

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "1000"
    delete_on_termination = true
  }

  associate_public_ip_address = true

  tags = {
    Name = local.launchpad_name
  }

  lifecycle {
    prevent_destroy = false
  }

}

output "ssh_connect" {
  value = "ssh -i ${local_file.kp.filename} ${var.aws_instance_user}@${aws_instance.ec2.public_dns}"
}