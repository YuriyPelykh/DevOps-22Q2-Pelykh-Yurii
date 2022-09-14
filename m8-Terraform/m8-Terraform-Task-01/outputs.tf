output "db-internal-ip" {
  value = module.db.db_ip
}

output "db-name" {
  value = module.db.db_name
}

output "db-user-name" {
  value = module.db.db_user_name
}

output "load-balancer-external-ip" {
  value = module.app-runtime-env.lb-external-ip
}


