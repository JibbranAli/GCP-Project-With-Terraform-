resource "google_compute_network" "vpc" {
  name                    = "${local.name_prefix}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${local.name_prefix}-subnet"
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.id
}

resource "google_compute_router" "nat_router" {
  name    = "${local.name_prefix}-router"
  region  = var.region
  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "${local.name_prefix}-nat"
  router                             = google_compute_router.nat_router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

resource "google_compute_firewall" "allow_lb_http" {
  name    = "${local.name_prefix}-allow-http"
  network = google_compute_network.vpc.id

  direction     = "INGRESS"
  source_ranges = local.lb_source_ranges
  target_tags   = ["web"]

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}

resource "google_compute_firewall" "allow_ssh" {
  count   = var.enable_ssh ? 1 : 0
  name    = "${local.name_prefix}-allow-ssh"
  network = google_compute_network.vpc.id

  direction     = "INGRESS"
  source_ranges = var.ssh_source_ranges
  target_tags   = ["web"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

