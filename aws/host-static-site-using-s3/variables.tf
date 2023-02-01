variable "domain_name" {
  type = string
}

variable "tags" {
  type        = map(string)
  description = "Tags"
}

variable "region" {}
