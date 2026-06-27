variable "project" {
  type    = string
  default = "multiregion-demo"
}

variable "environment" {
  type    = string
  default = "production"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "key_name" {
  description = "Name of keypair"
  type        = string
}

variable "allowed_ssh_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

variable "ecr_repository_url" {
  description = "ECR repository URL, e.g. 123456789.dkr.ecr.ap-southeast-3.amazonaws.com/myapp"
  type        = string
}