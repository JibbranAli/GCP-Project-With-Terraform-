locals {
  state_bucket_name = var.state_bucket_name != "" ? var.state_bucket_name : "${var.project_id}-tfstate"
}

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

data "google_project" "current" {
  project_id = var.project_id
}

resource "google_project_service" "required" {
  for_each = toset([
    "compute.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "sts.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "storage.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com"
  ])

  project            = var.project_id
  service            = each.key
  disable_on_destroy = false
}

resource "google_storage_bucket" "tf_state" {
  name                        = local.state_bucket_name
  location                    = var.state_bucket_location
  force_destroy               = false
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  public_access_prevention = "enforced"

  depends_on = [google_project_service.required]
}

resource "google_service_account" "ci" {
  account_id   = var.ci_service_account_name
  display_name = "Terraform CI"
}

resource "google_iam_workload_identity_pool" "github_pool" {
  provider                  = google-beta
  workload_identity_pool_id = "github-pool"
  display_name              = "GitHub Actions Pool"
  description               = "OIDC identity pool for GitHub Actions."
}

resource "google_iam_workload_identity_pool_provider" "github_provider" {
  provider                           = google-beta
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  display_name                       = "GitHub Actions Provider"
  description                        = "Trusts GitHub Actions OIDC tokens."

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
    "attribute.ref"        = "assertion.ref"
  }

  attribute_condition = "assertion.repository == \"${var.github_owner}/${var.github_repo}\""

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

resource "google_service_account_iam_member" "github_oidc" {
  service_account_id = google_service_account.ci.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${var.github_owner}/${var.github_repo}"
}

resource "google_project_iam_member" "ci_roles" {
  for_each = var.ci_sa_roles
  project  = var.project_id
  role     = each.key
  member   = "serviceAccount:${google_service_account.ci.email}"
}

