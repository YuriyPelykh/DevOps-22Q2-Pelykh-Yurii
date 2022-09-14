resource "google_compute_instance_template" "instance-template" {
  name = var.instance_template_name
  description = "This template is used to create app server instances."

  tags = ["allow-health-check"]

  labels = {
    environment = "dev"
  }

  instance_description = "description assigned to instances"
  machine_type = var.instance_type
  can_ip_forward = false

  scheduling {
    automatic_restart = true
    on_host_maintenance = "MIGRATE"
  }

  // Create a new boot disk from an image
  disk {
    source_image = "debian-cloud/debian-10"
    auto_delete = true
    boot = true
    disk_size_gb = 10
    disk_type = "pd-balanced"
    // Backup the disk every day:
    // resource_policies = [google_compute_resource_policy.daily_backup.id]
  }

  network_interface {
    network = var.instance_network
    subnetwork = var.instance_subnet

    //access_config {             //Making even empty access_config will create ephemeral External IP by default
    //  nat_ip = null             //To disable External IP access_config should be absent.
    //  network_tier = "PREMIUM"
    //}
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email = var.instance_service_account
    scopes = ["cloud-platform"]
  }

  metadata = {
    startup-script = "#! /bin/bash\napt-get -y install apache2\napt-get -y install libapache2-mod-php\napt-get -y install php-mysql\nrm -f /var/www/html/index.html\ngsutil cp -r gs://${var.app_bucket_name}/* /var/www/html/\nsed -i -r 's/([0-9]{1,3}\\.){3}[0-9]{1,3}/${var.db_instance_ip}/g' /var/www/html/db.php\nsystemctl restart apache2"
  }
}

//resource "google_compute_resource_policy" "daily_backup" {
//  name   = "every-day-4am"
//  region = "us-central1"
//  snapshot_schedule_policy {
//    schedule {
//      daily_schedule {
//        days_in_cycle = 1
//        start_time    = "04:00"
//      }
//    }
//  }
//}

resource "google_compute_instance_group_manager" "instance-group" {
  name = var.instance_group_name
  base_instance_name = "vm"
  zone = var.instance_group_zone
  target_size = 1

  version {
    instance_template  = google_compute_instance_template.instance-template.id
  }

  named_port {
    name = "http"
    port = 80
  }
}

resource "google_compute_firewall" "firewall" {
  name          = "fw-allow-health-check"
  direction     = "INGRESS"
  //network       = "global/networks/${var.instance_network}"
  network       = var.instance_network
  priority      = 1000
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["allow-health-check"]

  allow {
    ports    = ["80"]
    protocol = "tcp"
  }
}

resource "google_compute_health_check" "health_check" {
  name               = "http-basic-check"
  check_interval_sec = 5
  healthy_threshold  = 2
  http_health_check {
    port               = 80
    port_specification = "USE_FIXED_PORT"
    proxy_header       = "NONE"
    request_path       = "/"
  }
  timeout_sec         = 5
  unhealthy_threshold = 2
}

resource "google_compute_backend_service" "backend-service" {
  name                            = "web-backend-service"
  connection_draining_timeout_sec = 0
  health_checks                   = [google_compute_health_check.health_check.id]
  load_balancing_scheme           = "EXTERNAL_MANAGED"
  port_name                       = "http"
  protocol                        = "HTTP"
  session_affinity                = "NONE"
  timeout_sec                     = 30
  backend {
    group           = google_compute_instance_group_manager.instance-group.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

resource "google_compute_url_map" "url-map" {
  name            = "http-balancer"
  default_service = google_compute_backend_service.backend-service.id
}

resource "google_compute_target_http_proxy" "http-proxy" {
  name    = "http-lb-proxy"
  url_map = google_compute_url_map.url-map.id
}

resource "google_compute_global_forwarding_rule" "forwarding-rule" {
  name                  = "http-content-rule"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "80-80"
  target                = google_compute_target_http_proxy.http-proxy.id
  //ip_address            = google_compute_global_address.default.id      //Disabled for ephemeral IP. Static was not reserved.
}