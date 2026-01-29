variable "credentials" {
  description = "my credentials"
  default     = " "
}

variable "ssh_public_key" {
  description = "ssh_public_key"
  default     = " "
}

variable "project_id" {
  description = "Project"
  default     = " "
}

variable "region" {
  description = "Region"
  default     = " "
}

variable "zone" {
  description = "Zone"
  default     = " "
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

