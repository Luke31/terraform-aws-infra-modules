# Common S3-buckets for Datapipeline and Glue
# Bucket for input data to be processed
resource "aws_s3_bucket" "input_bucket" {
  bucket = "${var.bucket_prefix}-input"
  acl    = "private"
  force_destroy = true
}

# Input data
resource "aws_s3_bucket_object" "input_file" {
  bucket = aws_s3_bucket.input_bucket.bucket
  key    = var.input_file_key
  source = var.input_file_name
  etag = filemd5(var.input_file_name)
}

# Target-bucket for output
resource "aws_s3_bucket" "target_bucket" {
  bucket = "${var.bucket_prefix}-target"
  acl    = "private"
  force_destroy = true
}
