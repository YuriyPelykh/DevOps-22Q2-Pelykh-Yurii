resource "google_compute_global_address" "private-ip-address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  network       = var.db_network
  address       = "10.64.0.0"
  prefix_length = 24
}

resource "google_service_networking_connection" "private-vpc-connection" {
  network                 = var.db_network
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private-ip-address.name]
}

resource "random_id" "db_instance_name_suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "sql-database-instance" {
  name                 = "${var.db_instance_name}-${random_id.db_instance_name_suffix.hex}"
  region               = var.db_region
  database_version     = var.db_instance_version
  deletion_protection  = false
  depends_on           = [google_service_networking_connection.private-vpc-connection]

  settings {
    tier              = var.db_instance_type
    disk_size         = 10
    availability_type = "ZONAL"
    ip_configuration {
      ipv4_enabled    = false
      private_network = var.db_network
    }
  }

//  provisioner "remote-exec" {
//    inline = [
//      "mysql -u root -p${random_password.root-password.result} -e \"${file(var.db_schema_script)}\"",
//    ]
//  }
}

resource "google_sql_database" "sql-database" {
  name       = var.db_name
  instance   = google_sql_database_instance.sql-database-instance.name
}

resource "google_sql_user" "sql-user" {
  name       = var.db_user_name
  instance   = google_sql_database_instance.sql-database-instance.name
  host       = var.db_user_connect_host
  password   = var.db_user_password
}

