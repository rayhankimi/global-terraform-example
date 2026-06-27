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
  region = "ap-southeast-1"
}

module "ec2" {
  source = "../../modules/ec2"
  ecr_repository_url = var.ecr_repository_url
  project            = var.project
  environment        = var.environment
  region_alias       = "singapore"
  region_full        = "ap-southeast-1"
  availability_zone  = "ap-southeast-1a"
  vpc_cidr           = "10.20.0.0/16"      # Different CIDR to avoid overlap
  public_subnet_cidr = "10.20.1.0/24"
  instance_type      = var.instance_type
  key_name           = var.key_name
  allowed_ssh_cidr   = var.allowed_ssh_cidr
}