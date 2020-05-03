provider "aws" {
  region = "ap-northeast-1"
  profile = "lukas"
  assume_role {
    role_arn     = "arn:aws:iam::537595194483:role/OrganizationAccountAccessRole"
    session_name = "SESSION_NAME"
    external_id  = "EXTERNAL_ID"
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
  acl    = "private"
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
