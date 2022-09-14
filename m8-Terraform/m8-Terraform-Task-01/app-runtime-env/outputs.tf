output "lb-external-ip" {
  value = google_compute_global_forwarding_rule.forwarding-rule.ip_address
}
