variable "project" {
    description = "Project Name (Tagging)"
    type = string  
}

variable "environment" {
    description = "Environment (dev, staging, production)"
    type = string
    default = "production"
}

variable "source_bucket_name" {
    description = "Name of the S3 SOURCE bucket (Jakarta)"
    type = string
}

variable "destination_bucket_name" {
    description = "Name of the S3 DESTINATION bucket (Singapore)"
    type = string
}