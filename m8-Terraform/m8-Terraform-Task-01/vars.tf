//Project auth parameters:
variable "GOOGLE_SA_KEY" {
  description = "Path to Google Service Account key"
}

variable "GOOGLE_PROJ_ID" {
  description = "Cloud project name"
}

//Regional parameters:
variable "REGION" {
  description = "Region"
}

variable "ZONE" {
  description = "Zone"
}

//Network:
variable "VPC_NAME" {
  description = "VPC name"
}

variable "SUBNET_NAME" {
  description = "Subnet name"
}

variable "SUBNET_IP_RANGE" {
  description = "Sunnet IP-ranlge, e.g.: 172.16.20.0/24"
}

variable "CLOUD_ROUTER_NAME" {
  description = "Cloud router name"
}

variable "CLOUD_NAT_NAME" {
  description = "Cloud NAT name"
}


//Bucket Storage:
variable "TF_BUCKET_NAME" {
  description = "Bucket for terraform state-files name"
}

variable "TF_BUCKET_LOCATION" {
  description = "Terraform state-files bucket location"
}

variable "TF_BUCKET_CLASS" {
  description = "Terraform state-files bucket location"
}

variable "APP_BUCKET_NAME" {
  description = "php-mysql-crud application files bucket"
}

variable "APP_BUCKET_LOCATION" {
  description = "Application files bucket location"
}

variable "APP_BUCKET_CLASS" {
  description = "application files bucket class"
}

//IAM:
variable "SERVICE_ACCOUNT_ID" {
  description = "ID of Service Account been created"
}

variable "SERVICE_ACCOUNT_NAME" {
  description = "Name of Service Account been created"
}

variable "IAM_ROLES" {
  description = "IAM roles list, been applied to service account"
}

//Instance Template, Managed Instance Group, Load Balancer:
variable "INSTANCE_TEMPLATE_NAME" {
  description = "VM Instance Template name"
}

variable "INSTANCE_TYPE" {
  description = "Instance Type"
}

variable "INSTANCE_GROUP_NAME" {
  description = "Instance Group Manager name"
}

//Database:
variable "DB_NAME" {
  description = "App DB Name"
}

variable "DB_USER_NAME" {
  description = "App DB user name"
}

variable "DB_USER_PASSWORD" {
  description = "App DB user password"
}

variable "DB_INSTANCE_NAME" {
  description = "SQL Instance name"
}
variable "DB_INSTANCE_VERSION" {
  description = "SQL Instance version"
}

variable "DB_INSTANCE_TYPE" {
  description = "DB Instance type"
}










