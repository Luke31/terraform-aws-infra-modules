output "input_bucket_id" {
  value = aws_s3_bucket.input_bucket.id
}

output "input_bucket_domain_name" {
  value = aws_s3_bucket.input_bucket.bucket_domain_name
}

output "input_file_key" {
  value = aws_s3_bucket_object.input_file.key
}

output "target_bucket_id" {
  value = aws_s3_bucket.target_bucket.id
}
