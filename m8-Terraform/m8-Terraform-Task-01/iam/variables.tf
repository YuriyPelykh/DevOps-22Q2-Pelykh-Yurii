variable "project_id" {
  description = "The ID of the project where this SA will be created"
}

variable "service_account_id" {
  description = "ID of Service Account been created"
}

variable "service_account_name" {
  description = "Name of Service Account been created"
}

variable "iam_roles" {
  type        = list(string)
  description = "The list of IAM roles been created"
}
