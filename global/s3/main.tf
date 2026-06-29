terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
}

provider "aws" {
    region = "ap-southeast-3"
    alias = "jakarta"
  
}

provider "aws" {
    region = "ap-southeast-1"
    alias = "singapore"
}

module "s3" {
  source = "../../modules/s3"

  project = var.project
  environment             = var.environment
  source_bucket_name      = var.source_bucket_name
  destination_bucket_name = var.destination_bucket_name

  providers = {
    aws           = aws.jakarta
    aws.singapore = aws.singapore
  }
}