output "db_ip" {
  value = google_sql_database_instance.sql-database-instance.private_ip_address
}

output "db_name" {
  value = google_sql_database.sql-database.name
}

output "db_user_name" {
  value = google_sql_user.sql-user.name
}


