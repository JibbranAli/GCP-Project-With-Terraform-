resource "google_service_account" "instance_sa" {
  account_id   = "${local.name_prefix}-instance"
  display_name = "Web App Instance SA"
}

resource "google_project_iam_member" "instance_sa_logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.instance_sa.email}"
}

resource "google_project_iam_member" "instance_sa_monitoring" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.instance_sa.email}"
}

resource "google_project_iam_member" "instance_sa_storage" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.instance_sa.email}"
}

resource "google_compute_instance_template" "web" {
  name_prefix  = "${local.name_prefix}-template-"
  machine_type = var.machine_type
  tags         = ["web"]

  disk {
    source_image = "projects/debian-cloud/global/images/family/debian-12"
    auto_delete  = true
    boot         = true
  }

  disk {
    auto_delete  = true
    boot         = false
    disk_size_gb = var.data_disk_size_gb
    disk_type    = "pd-balanced"
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.id
  }

  service_account {
    email  = google_service_account.instance_sa.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  metadata_startup_script = local.startup_script

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }
}

resource "google_compute_instance_group_manager" "web" {
  name               = "${local.name_prefix}-mig"
  base_instance_name = "${local.name_prefix}-web"
  zone               = var.zone
  target_size        = var.instance_count

  version {
    instance_template = google_compute_instance_template.web.id
  }

  named_port {
    name = "http"
    port = 80
  }
}

