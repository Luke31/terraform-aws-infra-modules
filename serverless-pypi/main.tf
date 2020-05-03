module serverless_pypi {
  source  = "amancevice/serverless-pypi/aws"
  version = "~> 1.0"
  api_name                       = var.api_name
  api_endpoint_configuration_type = "REGIONAL"
  lambda_api_function_name       = "serverless-pypi-api"
  lambda_reindex_function_name   = "serverless-pypi-reindex"
  role_name                      = "serverless-pypi-role"
  s3_bucket_name                 = "${var.bucket_prefix}-${var.env}-serverless-pypi.example.com"
  s3_presigned_url_ttl           = 900
  fallback_index_url             = "https://pypi.org/simple/"
  api_authorization              = "CUSTOM"
  api_authorizer_id              = module.serverless_pypi_cognito.authorizer.id
}

module serverless_pypi_cognito {
  source               = "amancevice/serverless-pypi-cognito/aws"
  version              = "~> 0.2"
  api_id               = module.serverless_pypi.api.id
  lambda_function_name = "serverless-pypi-authorizer"
  role_name            = "serverless-pypi-authorizer-role"
  user_pool_name       = "serverless-pypi-cognito-pool"
}
