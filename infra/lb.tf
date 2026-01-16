resource "google_compute_health_check" "web" {
  name               = "${local.name_prefix}-hc"
  check_interval_sec = 5
  timeout_sec        = 5
  healthy_threshold  = 2
  unhealthy_threshold = 2

  http_health_check {
    port         = 80
    request_path = "/"
  }
}

resource "google_compute_backend_service" "web" {
  name                  = "${local.name_prefix}-backend"
  protocol              = "HTTP"
  port_name             = "http"
  load_balancing_scheme = "EXTERNAL"
  timeout_sec           = 30
  health_checks         = [google_compute_health_check.web.id]

  backend {
    group = google_compute_instance_group_manager.web.instance_group
  }
}

resource "google_compute_url_map" "web" {
  name            = "${local.name_prefix}-url-map"
  default_service = google_compute_backend_service.web.id
}

resource "google_compute_target_http_proxy" "web" {
  name    = "${local.name_prefix}-http-proxy"
  url_map = google_compute_url_map.web.id
}

resource "google_compute_global_address" "web" {
  name = "${local.name_prefix}-lb-ip"
}

resource "google_compute_global_forwarding_rule" "web" {
  name                  = "${local.name_prefix}-forwarding-rule"
  target                = google_compute_target_http_proxy.web.id
  ip_address            = google_compute_global_address.web.address
  port_range            = "80"
  load_balancing_scheme = "EXTERNAL"
}

