# Step-by-Step Guide: GCP + Terraform + GitHub Actions (Beginner Friendly)

This guide walks you through everything from zero to a fully automated GCP infrastructure deployment. No GCP Console clicking required after the one-time bootstrap.

## What you will build

- A custom VPC network
- Private VM instances behind a Load Balancer
- Cloud NAT for outbound access
- A Cloud Storage bucket for assets
- Secure CI/CD with GitHub Actions and manual approval

## Prerequisites (install once)

1. **Git**  
   Download: https://git-scm.com/downloads

2. **Terraform**  
   Download: https://developer.hashicorp.com/terraform/downloads  
   After installing, open a NEW PowerShell and run:
   ```powershell
   terraform -version
   ```
   If you see a version number, Terraform is installed correctly.
  If you get “terraform is not recognized”, close PowerShell and open it again.  
  If it still fails, reinstall Terraform and ensure it was added to your PATH.

3. **Google Cloud SDK (`gcloud`)**  
   Download: https://cloud.google.com/sdk/docs/install

4. **A GCP project with billing enabled**

5. **A GitHub repo** that contains this project

## Before you start (important terms)

- **project_id**: Your GCP project ID (example: `my-gcp-project-123`)
- **github_owner**: Your GitHub username or org name
- **github_repo**: The repository name on GitHub

You will replace placeholders like `YOUR_GCP_PROJECT_ID` with your real values.

## 0) Create a GitHub repo and push this project

Yes — you should push the code to GitHub first so GitHub Actions can run.

### Option A: Use an existing repo (recommended)

1. Create a new empty repo on GitHub (no README).
2. In PowerShell, run:

```powershell
cd "C:\Users\Jibbran\Documents\GCP Project"
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/YOUR_GITHUB_OR_ORG/YOUR_REPO_NAME.git
git push -u origin main
```

### Option B: If you already have a repo

Just make sure this project is pushed to your `main` branch.

## 1) Open PowerShell in the project folder

```powershell
cd "C:\Users\Jibbran\Documents\GCP Project"
```

## 2) Login to Google Cloud

```powershell
gcloud auth login
gcloud auth application-default login
```

Check that `gcloud` works:

```powershell
gcloud --version
```

Make sure your active project is correct:

```powershell
gcloud config set project YOUR_GCP_PROJECT_ID
```

## 3) Bootstrap (one-time setup)

This creates:
- A secure Terraform state bucket
- A GitHub OIDC identity
- A CI service account with least privilege

Run (replace the placeholders):

```powershell
cd .\bootstrap
terraform init
terraform apply `
  -var="project_id=YOUR_GCP_PROJECT_ID" `
  -var="github_owner=YOUR_GITHUB_OR_ORG" `
  -var="github_repo=YOUR_REPO_NAME"
```

Note: The backtick (`) is PowerShell’s line continuation. You can also run it as one line if you want.

When it finishes, **copy these outputs**:
- `state_bucket_name`
- `workload_identity_provider`
- `ci_service_account_email`

## 4) Add GitHub Secrets

Go to your GitHub repo → **Settings → Secrets and variables → Actions → New repository secret**

Add:

- `GCP_PROJECT_ID` = your GCP project id  
- `TF_STATE_BUCKET` = output `state_bucket_name`  
- `WIF_PROVIDER` = output `workload_identity_provider`  
- `TF_SA_EMAIL` = output `ci_service_account_email`

## 5) Create a GitHub Environment (manual approval)

Go to GitHub repo → **Settings → Environments**  
Create an environment named: **production**

Add required reviewers so the pipeline stops for approval before apply.

## 6) First Terraform init locally (optional check)

```powershell
cd ..\infra
terraform init -backend-config="bucket=YOUR_STATE_BUCKET" -backend-config="prefix=infra/state"
terraform plan -var="project_id=YOUR_GCP_PROJECT_ID"
```

## 7) Push to GitHub to trigger CI/CD

If you already pushed earlier, make any small change (like editing this file) and push again to trigger the pipeline.

```powershell
cd ..
git add .
git commit -m "Add GCP infra automation"
git push origin main
```

## 8) Watch the pipeline

Go to GitHub → **Actions**

You will see:
1. **Terraform fmt**
2. **Terraform validate**
3. **Terraform plan**
4. **Manual approval**
5. **Terraform apply**

Approve when prompted to deploy.

## 9) Get your Load Balancer URL

After apply, check Terraform outputs:

```powershell
cd .\infra
terraform output
```

Look for:
- `load_balancer_url`
- `load_balancer_ip`

Open the URL in your browser. You should see a basic NGINX page.

## Tips to avoid costs

- Default VM size is `e2-micro`
- Only 2 small instances are created
- You can destroy all resources with:

```powershell
cd .\infra
terraform destroy -var="project_id=YOUR_GCP_PROJECT_ID"
```

## Common problems

**Pipeline fails to authenticate**
- Check that GitHub secrets are correct
- Confirm Workload Identity provider output is correct

**No traffic on Load Balancer**
- Wait 2–5 minutes for health checks
- Check if instances are healthy in Terraform output

**Terraform init fails**
- Ensure state bucket exists (run bootstrap again)

---

You now have a full DevOps-style automation pipeline and infrastructure on GCP. If you want, I can add HTTPS, custom domain, autoscaling, or logging/monitoring dashboards.

