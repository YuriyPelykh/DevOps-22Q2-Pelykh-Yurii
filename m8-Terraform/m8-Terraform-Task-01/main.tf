terraform {
//  backend "gcs" {
//    bucket = "pmc-tfstate-bucket"
//    prefix = "terraform/state"
//    credentials = "C:/Users/Rocca/Desktop/epam-gcp-tf-3a080f9b9983.json"
//  }

//  cloud {
//    organization = "Yurii_Pelykh"
//
//    workspaces {
//      name = "pmc-workspace"
//    }
//  }

  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.34.0"
    }
  }
}

provider "google" {
  credentials = file(var.GOOGLE_SA_KEY)
  project     = var.GOOGLE_PROJ_ID
  region      = var.REGION
  zone        = var.ZONE
}

module "network" {
  source            = "./network"
  project_id        = var.GOOGLE_PROJ_ID
  network_name      = var.VPC_NAME
  subnet_name       = var.SUBNET_NAME
  subnet_ip_range   = var.SUBNET_IP_RANGE
  subnet_region     = var.REGION
  cloud_router_name = var.CLOUD_ROUTER_NAME
  cloud_nat_name    = var.CLOUD_NAT_NAME
}

module "iam" {
  source                = "./iam"
  project_id            = var.GOOGLE_PROJ_ID
  service_account_id    = var.SERVICE_ACCOUNT_ID
  service_account_name  = var.SERVICE_ACCOUNT_NAME
  iam_roles             = var.IAM_ROLES
}

module "db" {
  source                     = "./db"
  db_depends_on              = [module.network.vpc-network]
  db_name                    = var.DB_NAME
  db_user_name               = var.DB_USER_NAME
  db_user_password           = var.DB_USER_PASSWORD
  db_user_connect_host       = var.SUBNET_IP_RANGE
  db_instance_name           = var.DB_INSTANCE_NAME
  db_instance_version        = var.DB_INSTANCE_VERSION
  db_instance_type           = var.DB_INSTANCE_TYPE
  db_region                  = var.REGION
  db_network                 = module.network.vpc-network
}

//module "storage" {
//  source                = "./storage"
//  tf_bucket_name        = var.TF_BUCKET_NAME
//  tf_bucket_location    = var.TF_BUCKET_LOCATION
//  tf_bucket_class       = var.TF_BUCKET_CLASS
//  app_bucket_name       = var.APP_BUCKET_NAME
//  app_bucket_location   = var.APP_BUCKET_LOCATION
//  app_bucket_class      = var.APP_BUCKET_CLASS
//}

module "app-runtime-env" {
  source                     = "./app-runtime-env"
  app_runtime_env_depends_on = [module.iam.service-account-email, module.network.vpc-network, module.network.subnetwork, module.db.db_ip]
  instance_template_name     = var.INSTANCE_TEMPLATE_NAME
  instance_type              = var.INSTANCE_TYPE
  instance_network           = module.network.vpc-network
  instance_subnet            = var.SUBNET_NAME
  instance_service_account   = module.iam.service-account-email
  instance_group_name        = var.INSTANCE_GROUP_NAME
  instance_group_zone        = var.ZONE
  app_bucket_name            = var.APP_BUCKET_NAME
  db_instance_ip             = module.db.db_ip
}
