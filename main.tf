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
  bucket = "tf-test-bucket-${random_pet.suffix.id}"
}

output "bucket_name" {
  value = aws_s3_bucket.test_bucket.bucket
}
