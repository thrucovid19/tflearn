output "bucket-arn" {
  value       = aws_s3_bucket.tf-lifcycle-bucket.arn
  description = "Arn of the new bucket with lifecycle policy"
}