resource "google_service_account" "service-account" {
  account_id    = var.service_account_id
  display_name  = var.service_account_name
}

locals {
  roles = {
    for x in var.iam_roles :
    x => x
  }
}

resource "google_project_iam_member" "iam-role" {
  for_each  = local.roles
  project   = var.project_id
  role      = each.value
  member    = "serviceAccount:${google_service_account.service-account.email}"
}
