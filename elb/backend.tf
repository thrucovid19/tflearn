terraform {
  required_version = ">=0.12"
  backend "s3" {
    # Replace this with your bucket name!
    bucket = "all-projects-tf-states-727836929659"
    key    = "tfelb/terraform.tfstate"
    region = "us-east-1"
    # Replace this with your DynamoDB table name!
    dynamodb_table = "all-project-tf-locks-727836929659"
    encrypt        = true
  }
}