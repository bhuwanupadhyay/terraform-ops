locals {
  launchpad_name = var.launchpad_name
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


resource "aws_instance" "ec2" {
  ami               = var.aws_instance_ami
  instance_type     = var.aws_instance_type
  key_name          = aws_key_pair.kp.key_name

  root_block_device {
    volume_type           = "gp2"
    volume_size           = var.aws_volume_size
    delete_on_termination = var.aws_volume_delete_on_termination
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
