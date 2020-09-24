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

data "aws_iam_policy_document" "s3-access-doc" {
  statement {
    sid    = "ReadAndPutObjects"
    effect = "Allow"
    actions = [
      "s3:Get*",
      "s3:List*",
      "s3:AbortMultipartUpload",
      "s3:PutAnalyticsConfiguration",
      "s3:PutBucketNotification",
      "s3:PutObject"
    ]
    resources = [
      "${aws_s3_bucket.input_bucket.arn}/*",
    ]
  }

  statement {
    sid    = "AllowToListBucket"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:GetBucketLocation",
    ]
    resources = [
      aws_s3_bucket.input_bucket.arn,
    ]
  }
}

resource "aws_iam_policy" "s3-access" {
  name        = "s3-access"
  path        = "/"
  description = "This policy grants S3 access to roles used."
  policy      = data.aws_iam_policy_document.s3-access-doc.json
}

resource "aws_iam_role_policy_attachment" "batch-job-role-access-attachment" {
  role       = var.roles["batch-job-role"].name
  policy_arn = aws_iam_policy.s3-access.arn
}
