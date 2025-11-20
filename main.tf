terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "eu-west-3" # change if needed
}

# Generate a random suffix to make the bucket unique
resource "random_pet" "suffix" {}

resource "aws_s3_bucket" "test_bucket" {
  bucket = "tf-test-bucket-${random_pet.suffix.id}"
}

output "bucket_name" {
  value = aws_s3_bucket.test_bucket.bucket
}
