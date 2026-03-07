terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.17.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials)
  project     = var.project_id
  region      = var.region
  zone        = var.zone
}

# resource "google_compute_address" "n8n_static_ip" {
#   name = "n8n-static-ip"
# }

resource "google_compute_router" "n8n_router" {
  name    = "n8n-router"
  network = "default"
  region  = var.region
}

resource "google_compute_router_nat" "n8n_nat" {
  name                               = "n8n-nat-config"
  router                             = google_compute_router.n8n_router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_firewall" "n8n_firewall" {
  name    = "n8n-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = var.ports
  }

  source_ranges = var.source_ranges
  target_tags   = ["n8n-server"]

}

resource "google_compute_firewall" "allow_iap_ssh" {
  name        = "allow-iap-ssh"
  network     = "default"
  description = "Allow SSH access via Google Identity-Aware Proxy (IAP)"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
}

resource "google_compute_instance" "n8n_server" {
  name         = "n8n-server"
  machine_type = var.machine_type

  # the path of public ssh-key
  metadata = {
    ssh-keys = "n8n_user:${trimspace(file(var.ssh_public_key))}"
  }

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 10
    }
  }

  network_interface {
    network = "default"
    # access_config {
    #   nat_ip = google_compute_address.n8n_static_ip.address
    # }
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    curl -fsSL https://get.docker.com | sh
    usermod -aG docker $USER
    mkdir -p /home/n8n
  EOT

  tags = ["n8n-server"]
}

