variable "project" {
  description = "Project name used for tagging and naming resources"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, staging, production)"
  type        = string
  default     = "production"
}

variable "region_alias" {
  description = "Short alias for the region (e.g. jakarta, singapore)"
  type        = string
}

variable "region_full" {
  description = "Full AWS region name (e.g. ap-southeast-3)"
  type        = string
}

variable "availability_zone" {
  description = "Availability zone within the region"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of the EC2 Key Pair for SSH access"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into the instance (restrict to your IP in production)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "ecr_repository_url" {
  description = "ECR repository URL, e.g. 123456789.dkr.ecr.ap-southeast-3.amazonaws.com/myapp"
  type        = string
}