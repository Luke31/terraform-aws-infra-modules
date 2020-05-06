variable "env" {
  description = "environment-name e.g. dev or prod"
}
variable "bucket_prefix" {
  description = "bucket_prefix to create unique buckets. only lowercase alphanumeric characters and hyphens allowed. e.g. 'yourprefix-'"
}
variable "project_name" {
  description = "name of the project e.g. 'koike'"
}
variable "pip_index_url" {
  description = "index-url to use for pip"
}
