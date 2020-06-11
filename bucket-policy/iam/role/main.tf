resource "aws_iam_role" "batch-job-role" {
  name        = "batch-job-role"
  description = "Allows ECS tasks to call AWS services on your behalf."
  path        = "/"
  tags = {
  }
  assume_role_policy = data.aws_iam_policy_document.ecs-tasks-role.json
}

data "aws_iam_policy_document" "ecs-tasks-role" {
  statement {
    sid    = ""
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type = "Service"
      identifiers = [
        "ecs-tasks.amazonaws.com"
      ]
    }
  }
}
