variable "launchpad_name" {}
variable "aws_availability_zone" {}
variable "instance_ami" {}
variable "instance_type" {}
variable "spot_instance" { default = false }
variable "spot_price" { default = 0.5 }
variable "spot_type" { default = "one-time" }
variable "aws_instance_user" { default = "ubuntu" }