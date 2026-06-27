output "source_bucket_id" {
  value = module.s3.source_bucket_id
}

output "destination_bucket_id" {
  value = module.s3.destination_bucket_id
}

output "crr_role_arn" {
  value = module.s3.crr_role_arn
}