variable "db_depends_on" {
  description = "Formal variable"
}

variable "db_name" {
  description = "Database name"
}

variable "db_user_name" {
  description = "Database user"
}

variable "db_user_password" {
  description = "Database user password"
}

variable "db_user_connect_host" {
  description = "Hosts IP range, which may connect to database"
}

variable "db_instance_name" {
  description = "Database instance name"
}

variable "db_instance_version" {
  description = "Database version"
}

variable "db_instance_type" {
  description = "Database instance type"
}

variable "db_region" {
  description = "Database region"
}

variable "db_network" {
  description = "Database network"
}

variable "db_schema_script" {
  description = "Database schema script file"
  type = string
  default = "./db/schema.sql"
}

