terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
}
# ============================================================
# SOURCE RESOURCE (Jakarta)
# ============================================================

resource "aws_s3_bucket" "source" {
    # provider = aws.jakarta # Already default
    bucket = var.source_bucket_name

    tags = {
      Name = var.source_bucket_name
      Project = var.project
      Environment = var.environment
      Role = "Source"
      Region = "Jakarta"
    }
  
}

resource "aws_s3_bucket_versioning" "source" {
    bucket = aws_s3_bucket.source.id

    versioning_configuration {
      status = "Enabled"
    }
}

resource "aws_s3_bucket_intelligent_tiering_configuration" "source" {
    bucket = aws_s3_bucket.source.id
    name = "${var.project}-intelligent-tiering"
    status = "Enabled"

    tiering {
        access_tier = "ARCHIVE_ACCESS"
        days = 90
    }

    tiering {
      access_tier = "DEEP_ARCHIVE_ACCESS"
      days = 180
    }
}

resource "aws_s3_bucket_lifecycle_configuration" "name" {
    bucket = aws_s3_bucket.source.id

    depends_on = [ aws_s3_bucket_versioning.source ]
    
    rule {
      id = "nine-year-retention"
      status = "Enabled"

      # Apply to all objects in the bucker
      filter {}

      expiration {
        days = 9 * 365
      }

      noncurrent_version_expiration {
        noncurrent_days = 9 * 365
      }

      abort_incomplete_multipart_upload {
        days_after_initiation = 7
      }
    }
  
}

resource "aws_s3_bucket_public_access_block" "source" {
    bucket = aws_s3_bucket.source.id
    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
}



# ============================================================
# DESTINATION/REPLICA RESOURCE (Singapore)
# ============================================================

resource "aws_s3_bucket" "destination" {
    provider = aws.singapore
    bucket = var.destination_bucket_name

    tags = {
        Name = var.destination_bucket_name
        Project = var.project
        Environment = var.environment
        Role = "replica"
        Region = "singapore"
    }
}

resource "aws_s3_bucket_versioning" "destination" {
    provider = aws.singapore
    bucket = aws_s3_bucket.destination.id

    versioning_configuration {
        status = "Enabled"
    }
}

resource "aws_s3_bucket_intelligent_tiering_configuration" "destination" {
    provider = aws.singapore
    bucket = aws_s3_bucket.destination.id
    name = "${var.project}-intelligent-tiering-replica"
    status = "Enabled"
    
    tiering {
        access_tier = "ARCHIVE_ACCESS"
        days = 90
    }

    tiering {
      access_tier = "DEEP_ARCHIVE_ACCESS"
      days = 180
    }
}
  
resource "aws_s3_bucket_public_access_block" "destination" {
    provider = aws.singapore
    bucket = aws_s3_bucket.source.id
    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
}

resource "aws_iam_role_policy" "crr" {
  name = "${var.project}-s3-crr-policy"
  role = aws_iam_role.crr.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # Allow reading from source bucket
        Effect = "Allow"
        Action = [
          "s3:GetReplicationConfiguration",
          "s3:ListBucket"
        ]
        Resource = aws_s3_bucket.source.arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging"
        ]
        Resource = "${aws_s3_bucket.source.arn}/*"
      },
      {
        # Allow writing to destination bucket
        Effect = "Allow"
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"
        ]
        Resource = "${aws_s3_bucket.destination.arn}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_replication_configuration" "crr" {
  bucket = aws_s3_bucket.source.id
  role   = aws_iam_role.crr.arn

  depends_on = [aws_s3_bucket_versioning.source]

  rule {
    id     = "replicate-all-to-singapore"
    status = "Enabled"

    # Replicate all objects (no prefix filter)
    filter {}

    destination {
      bucket        = aws_s3_bucket.destination.arn
      storage_class = "INTELLIGENT_TIERING"
    }

    # Also replicate delete markers
    delete_marker_replication {
      status = "Enabled"
    }
  }
}