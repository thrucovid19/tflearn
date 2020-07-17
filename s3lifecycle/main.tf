provider "aws" {
  version                 = "~> 2.0"
  shared_credentials_file = var.credentials
  region                  = var.region
}

# Create s3 bucket with a lifecycle policy

resource "aws_s3_bucket" "tf-lifcycle-bucket" {
  bucket = "tf-lifecycle-project"
  acl = "private"
  lifecycle_rule {
    enabled = true
    transition {
      days = 30
      storage_class = "STANDARD_IA"
    }
    transition {
      days = 60
      storage_class = "GLACIER"
    }
  }
}