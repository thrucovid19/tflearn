output "bucket-arn" {
  value       = aws_s3_bucket.tf-lifecycle-bucket.arn
  description = "Arn of the new bucket with lifecycle policy"
}