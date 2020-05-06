variable "project_name" {
  description = "prefix for all project-resources"
}
variable "csv_header" {
  description = "list of csv headers"
}
variable "input_bucket_id" {}
#variable "input_bucket_domain_name" {}
variable "input_file_key" {}
variable "target_bucket_id" {}
variable "target_bucket_output_folder" {
  description = "output folder for processed result in target-bucket"
}