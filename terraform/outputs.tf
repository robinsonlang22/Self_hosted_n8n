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

# login
# output "ssh_connect_command" {
#   description = "Copy and paste this to connect to your server"
#   value       = "gcloud compute ssh ${google_compute_instance.vm_instance.name} --zone=${google_compute_instance.vm_instance.zone}"
# }

# instance status
# output "instance_status" {
#   value = google_compute_instance.vm_instance.instance_id
# }