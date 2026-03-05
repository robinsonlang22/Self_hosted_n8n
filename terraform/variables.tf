variable "credentials" {
  description = "my credentials"
  default     = "./keys/my_credentials.json"
}

variable "ssh_public_key" {
  description = "ssh_public_key"
  default     = "./keys/id_ed25519.pub"
}

variable "project_id" {
  description = "Project"
  default     = "n8n-server-485710"
}

variable "region" {
  description = "Region"
  default     = "europe-west3"
}

variable "zone" {
  description = "Zone"
  default     = "europe-west3-a"
}

variable "ports" {
  description = "Ports"
  type        = list(string)
  default     = ["80", "443"]
}

variable "source_ranges" {
  description = "source ranges"
  type        = list(string)
  default     = ["35.191.0.0/16", "130.211.0.0/22"]
}

variable "machine_type" {
  description = "machine type"
  default     = "e2-small"
}

variable "iap_client_id" {
  description = "Google OAuth Client ID for IAP"
  type        = string
}

variable "iap_client_secret" {
  description = "Google OAuth Client Secret for IAP"
  type        = string
  sensitive   = true
}

variable "iap_domains" {
  description = "the domains which apply Https IAP"
  type        = list(string)
}
