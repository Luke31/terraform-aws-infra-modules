# Common S3-buckets for Datapipeline and Glue
# Bucket for input data to be processed
resource "aws_s3_bucket" "input_bucket" {
  bucket = "${var.bucket_prefix}-test"
  acl    = "private"
  force_destroy = true
  tags = {
    "Environment" = var.env
  }
}

data "aws_iam_policy_document" "input_bucket" {

  statement {
      sid    = "DenyPutDeleteObject"
      effect = "Deny"
      principals {
        type        = "AWS"
        identifiers = ["*"]
      }
      actions = [
        "s3:PutObject",
        "s3:DeleteObject",
      ]
      resources = [
        "${aws_s3_bucket.input_bucket.arn}/*",
      ]
      condition {
      test     = "StringNotLike"
      variable = "aws:userId"
      values = [
        "${var.put_role_unique_id}:*", # assumed-role/batch-job-role
      ]
    }
  }

}

resource "aws_s3_bucket_policy" "input_bucket" {
  bucket = aws_s3_bucket.input_bucket.id
  policy = data.aws_iam_policy_document.input_bucket.json
}
