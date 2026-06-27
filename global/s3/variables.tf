variable "project" {
  description = "Project name"
  type        = string
  default     = "multiregion-demo"
}

variable "environment" {
  description = "Environment"
  type        = string
  default     = "production"
}

variable "source_bucket_name" {
  description = "Globally unique name for the Jakarta (source) S3 bucket"
  type        = string
}

variable "destination_bucket_name" {
  description = "Globally unique name for the Singapore (replica) S3 bucket"
  type        = string
}