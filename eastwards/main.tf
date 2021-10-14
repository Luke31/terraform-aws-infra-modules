terraform {
  required_version = "> 0.12.17"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.20"
    }
  }
}

// Help https://www.alexhyett.com/terraform-s3-static-website-hosting/#s3-static-website-infrastructure
resource "aws_s3_bucket" "eastwards_static_public" {
  bucket = "${var.bucket_prefix}-${var.env}-eastwards-static-public"
  acl    = "public-read"
//  cors_rule {
//    allowed_headers = ["Authorization", "Content-Length"]
//    allowed_methods = ["GET", "POST"]
//    allowed_origins = ["https://www.${var.domain_name}"]
//    max_age_seconds = 3000
//  }
  versioning {
    enabled = false
  }
  lifecycle {
    prevent_destroy = true
  }
  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

data "aws_iam_policy_document" "eastwards_static_public" {
  statement {
    sid    = "PublicReadGetObject"
    effect = "Allow"
    principals {
      type = "*"
      identifiers = ["*"]
    }
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.eastwards_static_public.id}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "eastwards_static_public" {
  bucket = aws_s3_bucket.eastwards_static_public.id
  policy = data.aws_iam_policy_document.eastwards_static_public.json
}
