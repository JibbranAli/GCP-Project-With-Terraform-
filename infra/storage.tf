resource "google_storage_bucket" "static_assets" {
  name                        = "${var.project_id}-${local.name_prefix}-assets"
  location                    = var.static_bucket_location
  force_destroy               = var.force_destroy_static_bucket
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  versioning {
    enabled = true
  }
}

