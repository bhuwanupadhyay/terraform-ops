variable "region" {}
variable "tags" {}
variable "launchpad_name" {}
variable "aws_instance_ami" {}
variable "aws_instance_type" {}
variable "aws_instance_user" {}
variable "aws_volume_size" { default = 20 }
variable "aws_volume_delete_on_termination" { default = true }
variable "spot_instance" { default = false }