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

resource "google_compute_address" "n8n_static_ip" {
  name = "n8n-static-ip"
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

  # 核心解药：这是 Google IAP 中转服务器的专用 IP 段
  # 只有来自这里的流量才允许通过 22 端口，其他的（比如公网黑客）全部拦截
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
    access_config {
      nat_ip = google_compute_address.n8n_static_ip.address
    }
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    curl -fsSL https://get.docker.com | sh
    usermod -aG docker $USER
    mkdir -p /home/n8n
  EOT

  tags = ["n8n-server"]
}

