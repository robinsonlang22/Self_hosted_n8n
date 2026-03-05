# apply a global address for load-balancer
resource "google_compute_global_address" "iap_lb_ip" {
  name = "n8n-iap-global-ip"
}

# create unmanaged instance group, let LB can find my VM
resource "google_compute_instance_group" "n8n_ig" {
  name = "n8n-instance-group"
  zone = var.zone
  # add instance as self_link format in list instnaces
  instances = [google_compute_instance.n8n_server.self_link]

  named_port {
    name = "http"
    # flow through port 80 to Traefik
    port = 80
  }

  named_port {
    name = "https"
    port = 443
  }
}

# health check: BL confirms that Traefik is alive
resource "google_compute_health_check" "n8n_health_check" {
  name = "n8n-health-check"
  tcp_health_check {
    port = 443
    # request_path = "/"
  }
  check_interval_sec = 5
  timeout_sec        = 5
}

# public backend service
resource "google_compute_backend_service" "public_backend" {
  name                  = "public-site-backend"
  protocol              = "HTTPS"
  port_name             = "https"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  health_checks         = [google_compute_health_check.n8n_health_check.id]

  backend {
    group = google_compute_instance_group.n8n_ig.id
  }

  iap {
    enabled = false
  }

}

# IAP backend service
resource "google_compute_backend_service" "n8n_backend" {
  name                  = "n8n-backend-service"
  protocol              = "HTTPS"
  port_name             = "https"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  health_checks         = [google_compute_health_check.n8n_health_check.id]

  backend {
    group = google_compute_instance_group.n8n_ig.id
  }

  iap {
    enabled              = true
    oauth2_client_id     = var.iap_client_id
    oauth2_client_secret = var.iap_client_secret
  }
}

resource "google_compute_firewall" "allow_lb_to_vm" {
  name    = "allow-gclb-to-n8n"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  # specific IP for Google BL and Health Check
  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
  target_tags   = ["n8n-server"]
}

# map url, let outside flow appoint to iap_backend 
resource "google_compute_url_map" "n8n_url_map" {
  name            = "n8n-url-map"
  default_service = google_compute_backend_service.public_backend.id

  host_rule {
    hosts        = var.iap_domains
    path_matcher = "n8n-matcher"
  }

  host_rule {
    hosts        = ["ushuaialang.com", "www.ushuaialang.com"]
    path_matcher = "public-matcher"
  }

  path_matcher {
    name            = "n8n-matcher"
    default_service = google_compute_backend_service.n8n_backend.id
  }

  path_matcher {
    name            = "public-matcher"
    default_service = google_compute_backend_service.public_backend.id
  }

}

# manage SSL certification by Google
resource "google_compute_managed_ssl_certificate" "n8n_managed_cert" {
  name = "n8n-managed-cert-v3"
  managed {
    domains = ["n8n.ushuaialang.com", "ushuaialang.com", "www.ushuaialang.com"]
  }
  lifecycle {
    create_before_destroy = true
  }
}

# target HTTPS Proxy
resource "google_compute_target_https_proxy" "n8n_https_proxy" {
  name             = "n8n-https-proxy"
  url_map          = google_compute_url_map.n8n_url_map.id
  ssl_certificates = [google_compute_managed_ssl_certificate.n8n_managed_cert.id]
}

# bind global address with port 443
resource "google_compute_global_forwarding_rule" "n8n_https_forwarding_rule" {
  name                  = "n8n-https-forwarding-rule"
  ip_address            = google_compute_global_address.iap_lb_ip.address
  ip_protocol           = "TCP"
  port_range            = "443"
  target                = google_compute_target_https_proxy.n8n_https_proxy.id
  load_balancing_scheme = "EXTERNAL_MANAGED"
}

