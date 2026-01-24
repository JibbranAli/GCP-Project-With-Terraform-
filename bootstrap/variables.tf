variable "project_id" {
  description = "GCP project id to bootstrap."
  type        = string
}

variable "region" {
  description = "Default region for bootstrap resources."
  type        = string
  default     = "us-central1"
}

variable "state_bucket_name" {
  description = "Optional override for the Terraform state bucket name."
  type        = string
  default     = ""
}

variable "state_bucket_location" {
  description = "Location for the Terraform state bucket."
  type        = string
  default     = "US"
}

variable "ci_service_account_name" {
  description = "Service account name used by GitHub Actions."
  type        = string
  default     = "terraform-ci"
}

variable "github_owner" {
  description = "GitHub org or user that owns the repo."
  type        = string
}

variable "github_repo" {
  description = "GitHub repo name."
  type        = string
}

variable "ci_sa_roles" {
  description = "Project roles granted to the CI service account."
  type        = set(string)
  default = [
    "roles/compute.admin",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.serviceAccountUser",
    "roles/storage.admin",
    "roles/resourcemanager.projectIamAdmin"
  ]
}


