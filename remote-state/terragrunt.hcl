# This shouldn't be finally here - use terraform-aws-infra-live
remote_state {
  backend = "s3"
  config = {
    bucket         = "sc-dev-tfstate"
    key            = "terraform.tfstate"
    region         = "ap-northeast-1"
    encrypt        = true
    dynamodb_table = "app-state"
    role_arn       = "arn:aws:iam::537595194483:role/OrganizationAccountAccessRole"
  }
}
