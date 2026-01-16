output "state_bucket_name" {
  description = "GCS bucket name for Terraform state."
  value       = google_storage_bucket.tf_state.name
}

output "workload_identity_provider" {
  description = "Workload identity provider resource name for GitHub Actions."
  value       = google_iam_workload_identity_pool_provider.github_provider.name
}

output "ci_service_account_email" {
  description = "Service account used by GitHub Actions."
  value       = google_service_account.ci.email
}

output "project_number" {
  description = "Project number for reference."
  value       = data.google_project.current.number
}

