variable "instance_template_name" {
  description = "The name of Instance Template"
}

variable "instance_group_name" {
  description = "The name of Instance Group Manager"
}

variable "instance_type" {
  description = "Type of instance machine"
}

variable "instance_network" {
  description = "Network name, where instances been created"
}

variable "instance_subnet" {
  description = "Network name, where instances been created"
}

variable "instance_service_account" {
  description = "Service account Email, created in module 'iam'"
}

variable "instance_group_zone" {
  description = "Zone for instance group creation"
}

variable "app_bucket_name" {
  description = "Application Storage Bucket name"
}

variable "app_runtime_env_depends_on" {
  description = "Formal variable"
}

variable "db_instance_ip" {
  description = "IP address of SQL DB instance"
}







