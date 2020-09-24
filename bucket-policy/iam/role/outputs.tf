output "roles" {
  value = {
    (aws_iam_role.batch-job-role.name) = aws_iam_role.batch-job-role.name,
    (aws_iam_role.batch-job-role.unique_id) = aws_iam_role.batch-job-role.unique_id
  }
}
