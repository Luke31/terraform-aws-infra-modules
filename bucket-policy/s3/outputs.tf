output "input_bucket_id" {
  value = aws_s3_bucket.input_bucket.id
}

output "input_bucket_domain_name" {
  value = aws_s3_bucket.input_bucket.bucket_domain_name
}
