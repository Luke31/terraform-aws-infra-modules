terraform {
  required_version = "> 0.12.17"
  required_providers {
    aws = "> 2.40.0"
  }
}

# Input bucket
module "s3" {
  source     = "./s3/input_bucket"
  env = var.env
  bucket_prefix = "${var.bucket_prefix}-${var.env}-${var.project_name}"
  roles = module.iam.roles
}

# Role
module "iam" {
  source     = "./iam/role"
}
