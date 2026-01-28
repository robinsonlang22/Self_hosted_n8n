variable "credentials" {
  description = "my credentials"
  default     = "./keys/my_credentials.json"
}

variable "ssh_public_key" {
  description = "ssh_public_key"
  default     = "./keys/gcp_n8n.pub"
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
  default     = ["22", "80", "443"]
}

variable "source_ranges" {
  description = "source ranges"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "machine_type" {
  description = "machine type"
  default     = "e2-small"
}

