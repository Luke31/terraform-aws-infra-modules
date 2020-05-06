# Try terragrunt before-hook to make site-packages.zip?

# AWS Glue
resource "aws_glue_catalog_database" "catalog_database" {
  name = "${var.project_name}-database"
}

resource "aws_glue_classifier" "classifier_csv" {
  name = "${var.project_name}-classifier-csv"

  csv_classifier {
    allow_single_column    = false
    contains_header        = "PRESENT"
    delimiter              = ","
    disable_value_trimming = false
    header                 = var.csv_header
    quote_symbol           = "'"
  }
}

resource "aws_glue_crawler" "crawler" {
  database_name = aws_glue_catalog_database.catalog_database.name
  name          = "${var.project_name}_crawler"
  role          = aws_iam_role.glue.arn

  s3_target {
    path = "s3://${var.input_bucket_id}/${var.input_file_key}"
  }
}

# Daily trigger for crawler
resource "aws_glue_trigger" "crawler_scheduled_daily" {
  name     = "${var.project_name}_crawler_scheduled_daily"
  schedule = "cron(5 12 * * ? *)"
  type     = "SCHEDULED"

  actions {
    crawler_name = aws_glue_crawler.crawler.name
  }
}

# Glue script in Amazon S3 for Glue job
resource "aws_s3_bucket_object" "glue_script" {
  bucket = var.input_bucket_id
  key    = "glue/etlglue.py"
  source = "${path.module}/etlglue.py"
  etag = filemd5("${path.module}/etlglue.py")
}

# Libraries for glue script
resource "null_resource" "glue_script_side_packages" {
  triggers = {
    requirements_file = filemd5("${path.module}/requirements.txt")
  }
  provisioner "local-exec" {
    command = "rm -f \"${path.module}/site-packages.zip\""
  }
  provisioner "local-exec" {
    command = "pip install -i ${var.pip_index_url} -r \"${path.module}/requirements.txt\" --target=site-packages"
  }
  provisioner "local-exec" {
    command = "zip -r -X \"${path.module}/site-packages.zip\" site-packages"
  }
}

# Glue script library in Amazon S3 for Glue job
resource "aws_s3_bucket_object" "glue_script_libs" {
  depends_on = [null_resource.glue_script_side_packages]
  bucket = var.input_bucket_id
  key    = "glue/site-packages.zip"
  source = "${path.module}/site-packages.zip"
  # etag = filemd5("${path.module}/site-packages.zip")
}

resource "aws_glue_job" "glue_job" {
  name     = "${var.project_name}_glue_job"
  role_arn = aws_iam_role.glue.arn

  command {
    script_location = "s3://${var.input_bucket_id}/${aws_s3_bucket_object.glue_script.key}"
  }

  default_arguments = {
    "--extra-py-files": "s3://${var.input_bucket_id}/${aws_s3_bucket_object.glue_script_libs.key}"
    "--target_bucket_folder": "s3://${var.target_bucket_id}/${var.target_bucket_output_folder}",
    "--glue_database": aws_glue_catalog_database.catalog_database.name,
    "--glue_table_name": replace(basename(var.input_file_key),".","_"),
  }
}

# Trigger for job
resource "aws_glue_trigger" "glue_job_scheduled" {
  name     = "${var.project_name}_glue_job_scheduled"
  schedule = "cron(15 12 31 * ? *)"
  type     = "SCHEDULED"

  actions {
    job_name = aws_glue_job.glue_job.name
  }
}

# AWS role for glue
resource "aws_iam_role" "glue" {
  name = "AWSGlueServiceRoleDefault"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "glue.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# AWS policy: Attach default glue policy to glue role (allows also to write logs)
resource "aws_iam_role_policy_attachment" "glue_service" {
    role = aws_iam_role.glue.id
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

# AWS policy: allow to read/write from input bucket
resource "aws_iam_role_policy" "AWSGlueServiceRoleDefault-S3-bucket" {
  name = "AWSGlueServiceRoleDefaultInputBucket"
  role = aws_iam_role.glue.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::${var.input_bucket_id}/*",
        "arn:aws:s3:::${var.target_bucket_id}/*"
      ]
    }
  ]
}
EOF
}
