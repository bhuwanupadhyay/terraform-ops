locals {
  launchpad_name = var.launchpad_name

  vpc_cidr = "10.0.0.0/16"
}

resource "aws_vpc" "vps-env" {
  cidr_block           = local.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_subnet" "subnet-uno" {
  cidr_block        = cidrsubnet(aws_vpc.vps-env.cidr_block, 3, 1)
  vpc_id            = aws_vpc.vps-env.id
  availability_zone = var.aws_availability_zone
}

resource "aws_security_group" "ingress-ssh-vps" {
  name   = "allow-ssh-sg"
  vpc_id = aws_vpc.vps-env.id

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]

    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# ssh key
resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ssh_key" {
  key_name   = local.launchpad_name
  public_key = tls_private_key.pk.public_key_openssh
}

resource "local_file" "ssh_key" {
  filename        = "${path.cwd}/build/ssh_${local.launchpad_name}.pem"
  content         = sensitive(tls_private_key.pk.private_key_pem)
  file_permission = "400"
}

resource "aws_spot_instance_request" "spot" {
  ami                         = var.instance_ami
  spot_price                  = var.spot_price
  instance_type               = var.instance_type
  spot_type                   = var.spot_type
  # block_duration_minutes = 120
  wait_for_fulfillment        = true
  key_name                    = aws_key_pair.ssh_key.key_name
  count                       = var.spot_instance ? 1 : 0
  associate_public_ip_address = true

  security_groups = [
    aws_security_group.ingress-ssh-vps.id
  ]
  subnet_id = aws_subnet.subnet-uno.id
}

resource "aws_instance" "on_demand" {
  ami                         = var.instance_ami
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.ssh_key.key_name
  subnet_id                   = aws_subnet.subnet-uno.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [
    aws_security_group.ingress-ssh-vps.id
  ]
  count = var.spot_instance ? 0 : 1
}

locals {
  public_dns = var.spot_instance ? aws_spot_instance_request.spot.0.public_dns : aws_instance.on_demand.0.public_dns
}

output "ssh_connect" {
  value = "ssh -i ${local_file.ssh_key.filename} ${var.aws_instance_user}@${local.public_dns}"
}