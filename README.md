# GCP Web App Infrastructure with Terraform + GitHub Actions

End-to-end, production-style infrastructure automation on Google Cloud. This project provisions a full web application stack with a custom VPC, private compute instances behind a global HTTP load balancer, Cloud NAT for outbound access, and Cloud Storage for static assets. CI/CD is handled by GitHub Actions with a manual approval gate.

## What this builds

- Custom VPC, subnetwork, and firewall rules
- Private Compute Engine instances (Managed Instance Group)
- Cloud NAT for outbound package installs without public IPs
- Global HTTP Load Balancer routing to the instance group
- Cloud Storage bucket for static assets
- Least-privilege IAM for instances and CI/CD
- Terraform state stored securely in a GCS bucket

## Repo structure

- `bootstrap/` — creates state bucket + GitHub OIDC identity + CI service account
- `infra/` — main infrastructure (VPC, compute, load balancer, storage)
- `.github/workflows/terraform.yml` — CI/CD pipeline

## Prerequisites

- A GCP project with billing enabled
- Terraform installed on Windows
- `gcloud` installed and authenticated (for bootstrap)
- A GitHub repo containing this code

## Bootstrap (one-time)

This step creates a secure Terraform state bucket and a least-privilege service account for GitHub Actions using Workload Identity Federation.

In PowerShell (run from the repo root):

```powershell
cd "C:\Users\Jibbran\Documents\GCP Project"
gcloud auth application-default login
cd .\bootstrap
terraform init
terraform apply `
  -var="project_id=YOUR_GCP_PROJECT_ID" `
  -var="github_owner=YOUR_GITHUB_ORG_OR_USER" `
  -var="github_repo=YOUR_REPO_NAME"
```

Capture the outputs:

- `state_bucket_name`
- `workload_identity_provider`
- `ci_service_account_email`

## GitHub secrets

Add these GitHub secrets in your repo:

- `GCP_PROJECT_ID` = your GCP project id
- `TF_STATE_BUCKET` = state bucket name (from bootstrap output)
- `WIF_PROVIDER` = workload identity provider (from bootstrap output)
- `TF_SA_EMAIL` = CI service account email (from bootstrap output)

Create a GitHub Environment named `production` and configure required reviewers.

## CI/CD flow (GitHub Actions)

On every push to `main`:

1. `terraform fmt` and `terraform validate`
2. `terraform plan`
3. Manual approval (GitHub environment)
4. `terraform apply`

## Local usage (optional)

You can also run the main infrastructure locally:

```powershell
cd .\infra
terraform init -backend-config="bucket=YOUR_STATE_BUCKET" -backend-config="prefix=infra/state"
terraform plan -var="project_id=YOUR_GCP_PROJECT_ID"
terraform apply -var="project_id=YOUR_GCP_PROJECT_ID"
```

## Outputs

After apply:

- `load_balancer_ip` — public IP of the web app
- `load_balancer_url` — full URL you can open in a browser
- `static_bucket_name` — storage bucket for assets

## Notes

- The default configuration uses small machines and private instances to keep cost low.
- SSH access is restricted by default to IAP ranges. You can control this in `infra/variables.tf`.
- The load balancer is HTTP only. You can extend to HTTPS with a managed certificate.


