terraform {
  required_version = ">= 1.13.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.21"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }
  }
}

provider "aws" {
  region = "eu-west-3" # change if needed
}

# Generate a random suffix to make the bucket unique
resource "random_pet" "suffix" {}

resource "aws_s3_bucket" "test_bucket" {
  bucket = "qovery-test-bucket-${random_pet.suffix.id}"
}

data "aws_caller_identity" "current" {}

output "bucket_name" {
  value = aws_s3_bucket.test_bucket.bucket
}

output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

# Keep the bucket private and encrypted, expire old objects
resource "aws_s3_bucket_public_access_block" "test_bucket" {
  bucket = aws_s3_bucket.test_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "test_bucket" {
  bucket = aws_s3_bucket.test_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "test_bucket" {
  bucket = aws_s3_bucket.test_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "test_bucket" {
  bucket = aws_s3_bucket.test_bucket.id

  # Noncurrent-version rules need versioning to exist first
  depends_on = [aws_s3_bucket_versioning.test_bucket]

  rule {
    id     = "expire-old-objects"
    status = "Enabled"
    filter {}
    expiration {
      days = 30
    }
    noncurrent_version_expiration {
      noncurrent_days = 30
    }
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }

  rule {
    id     = "expire-delete-markers"
    status = "Enabled"
    filter {}
    expiration {
      expired_object_delete_marker = true
    }
  }
}
