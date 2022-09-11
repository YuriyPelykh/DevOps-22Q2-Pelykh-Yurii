resource "google_storage_bucket" "tfstate-bucket" {
  name = var.tf_bucket_name
  force_destroy = false
  location      = var.tf_bucket_location
  storage_class = var.tf_bucket_class
  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_storage_bucket" "app-bucket" {
  name = var.app_bucket_name
  force_destroy = false
  location      = var.app_bucket_location
  storage_class = var.app_bucket_class
  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}