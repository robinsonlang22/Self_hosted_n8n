# static public IP
output "n8n_public_ip" {
  description = "The static public IP address of the n8n server"
  value       = google_compute_address.n8n_static_ip.address
}

# temporare url address
output "n8n_ui_url" {
  description = "The temporary URL to access n8n (before DNS is ready)"
  value       = "http://${google_compute_address.n8n_static_ip.address}:5678"
}

# global ip
output "n8n_global_ip" {
  value = google_compute_global_address.iap_lb_ip.address
}