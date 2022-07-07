provider "aws" {
  region  = var.region
  profile = "default"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "eks-terraform-subin-s3-13377"

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_versioning" "versioning_s3" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "main_terraform_state_lock" {
  name           = "eks-terraform-state"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

