terraform {
  required_version = "> 0.12.17"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.20"
    }
  }
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.bucket_prefix}-${var.env}-tfstate"
  versioning {
    enabled = true
  }
  lifecycle {
    prevent_destroy = true
  }
  acl = "private"
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "app-state"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
