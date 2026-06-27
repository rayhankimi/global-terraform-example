terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-3"
}

module "ec2" {
    source = "../../modules/ec2"
    ecr_repository_url = var.ecr_repository_url
    project            = var.project
    environment        = var.environment
    region_alias       = "jakarta"
    region_full        = "ap-southeast-3"
    availability_zone  = "ap-southeast-3a"
    vpc_cidr           = "10.10.0.0/16"
    public_subnet_cidr = "10.10.1.0/24"
    instance_type      = var.instance_type
    key_name           = var.key_name
    allowed_ssh_cidr   = var.allowed_ssh_cidr
}