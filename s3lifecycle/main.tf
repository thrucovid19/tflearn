provider "aws" {
  version                 = "~> 2.0"
  shared_credentials_file = var.credentials
  region                  = var.region
}

# Create s3 bucket with a lifecycle policy

resource "aws_s3_bucket" "tf-lifecycle-bucket" {
  bucket = "tf-lifecycle-project"
  acl    = "private"
  lifecycle_rule {
    enabled = true
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
    transition {
      days          = 60
      storage_class = "GLACIER"
    }
  }
}

resource "aws_s3_bucket_policy" "tf-s3-bucket-policy" {
  bucket = aws_s3_bucket.tf-lifecycle-bucket.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "tf-bucket-policy",
  "Statement": [
    {
      "Sid": "IPAllow",
      "Effect": "Allow",
      "Principal": "*",
       "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::tf-lifecycle-project*"
    }
  ]
}
POLICY
}