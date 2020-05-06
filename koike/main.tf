terraform {
  required_version = "> 0.12.17"
  required_providers {
    aws = "> 2.40.0"
  }
}

# Input- and Target bucket
module "buckets" {
  source     = "./buckets"
  bucket_prefix = "${var.bucket_prefix}-${var.env}-${var.project_name}"
  input_file_name = "inputdata/tweets_koike.csv"
  input_file_key = "inputdata/tweets_koike.csv"
}

module "glue" {
  source     = "./glue"
  project_name = var.project_name
  input_bucket_id = module.buckets.input_bucket_id
  input_file_key = module.buckets.input_file_key
  target_bucket_id = module.buckets.target_bucket_id
  csv_header = ["utc", "tweetid","user","text"]
  target_bucket_output_folder = "glue_output/tweets_emotion"
}
