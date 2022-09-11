variable "tf_bucket_name" {
  description = "The name of Terraform state file bucket"
}

variable "tf_bucket_location" {
  description = "Location of bucket, where Terraform state file been saved"
}

variable "tf_bucket_class" {
  description = "Class of bucket, where Terraform state file been saved"
}

variable "app_bucket_name" {
  description = "Bucket name, where app files been stored"
}

variable "app_bucket_location" {
  description = "Bucket location, where app files been stored"
}

variable "app_bucket_class" {
  description = "Bucket class, where app files been stored"
}

