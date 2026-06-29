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
  description = "Name of the keypair (auto generated)"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "Allowed ip to do ssh"
  type        = string
  default     = "0.0.0.0/0"
}

variable "ecr_repository_url" {
  description = "ECR Repository URL that contain docker image that you want to deploy"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket name that has been deployed in another module"
  type = string
}