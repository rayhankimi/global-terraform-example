output "source_bucket_id" {
  description = "ID of the source S3 bucket (Jakarta)"
  value       = aws_s3_bucket.source.id
}

output "source_bucket_arn" {
  description = "ARN of the source S3 bucket"
  value       = aws_s3_bucket.source.arn
}

output "destination_bucket_id" {
  description = "ID of the destination S3 bucket (Singapore)"
  value       = aws_s3_bucket.destination.id
}

output "destination_bucket_arn" {
  description = "ARN of the destination S3 bucket"
  value       = aws_s3_bucket.destination.arn
}

output "crr_role_arn" {
  description = "ARN of the IAM role used for Cross-Region Replication"
  value       = aws_iam_role.crr.arn
}