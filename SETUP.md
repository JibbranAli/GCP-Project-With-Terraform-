# GCP Terraform + GitHub Actions Setup Manual (Beginner Friendly)

This manual walks you through a complete, end-to-end setup of the GCP infrastructure automation project. It is written for beginners and explains what each step does and why it is needed.

## 1. What this project builds

After this setup, Terraform and GitHub Actions will automatically create:
- A custom VPC and subnet
- Private VM instances (Managed Instance Group)
- Cloud NAT for outbound access
- A global HTTP Load Balancer
- A Cloud Storage bucket for static assets
- IAM with least-privilege access

## 2. Important terms (read first)

- **project_id**: Your GCP project ID (example: `my-gcp-project-123`)
- **github_owner**: Your GitHub username or org name (example: `JibbranAli`)
- **github_repo**: The repo name only (example: `GCP-Project-With-Terraform-`)

You will replace placeholders like `YOUR_GCP_PROJECT_ID` with your real values.

## 3. Prerequisites (install once)

1. **Git**  
   Download: https://git-scm.com/downloads

2. **Terraform**  
   Download: https://developer.hashicorp.com/terraform/downloads  
   After installing, open a NEW PowerShell and run:
   ```powershell
   terraform -version
   ```
   If you see a version number, Terraform is installed correctly.  
   If you get “terraform is not recognized”, reopen PowerShell. If it still fails, reinstall and ensure it is added to PATH.

3. **Google Cloud SDK (`gcloud`)**  
   Download: https://cloud.google.com/sdk/docs/install  
   After installing, open a NEW PowerShell and run:
   ```powershell
   gcloud --version
   ```

4. **A GCP project with billing enabled**  
   Billing must be ON to enable Compute Engine.

5. **A GitHub repo** that contains this project  
   GitHub Actions runs from your repo.

## 4. Create a GitHub repo and push this project

You must push the code to GitHub so Actions can run.

### 4.1 Create a new repo on GitHub

Create an empty repo (no README). Note the URL:
```
https://github.com/YOUR_GITHUB_OR_ORG/YOUR_REPO_NAME.git
```

### 4.2 Push this project to GitHub

```powershell
cd "C:\Users\Jibbran\Documents\GCP Project"
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/YOUR_GITHUB_OR_ORG/YOUR_REPO_NAME.git
git push -u origin main
```

## 5. Login to Google Cloud

```powershell
gcloud auth login
gcloud auth application-default login
```

Set your active project:
```powershell
gcloud config set project YOUR_GCP_PROJECT_ID
```

## 6. Bootstrap (one-time setup)

Bootstrap creates:
- A secure Terraform state bucket (GCS)
- GitHub Workload Identity (OIDC)
- A CI service account with least privilege

Run from the bootstrap folder:

```powershell
cd "C:\Users\Jibbran\Documents\GCP Project\bootstrap"
terraform init
terraform apply `
  -var="project_id=YOUR_GCP_PROJECT_ID" `
  -var="github_owner=YOUR_GITHUB_OR_ORG" `
  -var="github_repo=YOUR_REPO_NAME"
```

Note: The backtick (`) is PowerShell’s line continuation. You can also run it as one line.

### 6.1 Save the outputs

After apply, run:
```powershell
terraform output
```

Copy and keep these three values:
- `state_bucket_name`
- `workload_identity_provider`
- `ci_service_account_email`

## 7. Add GitHub secrets

In your GitHub repo:
**Settings → Secrets and variables → Actions → New repository secret**

Add:
- `GCP_PROJECT_ID` = your GCP project id  
- `TF_STATE_BUCKET` = output `state_bucket_name`  
- `WIF_PROVIDER` = output `workload_identity_provider`  
- `TF_SA_EMAIL` = output `ci_service_account_email`

## 8. Create a GitHub Environment (manual approval)

Go to: **Settings → Environments**  
Create an environment named: **production**  
Add required reviewers so the pipeline pauses for approval before apply.

## 9. Trigger the CI/CD pipeline

Push a change to `main`:

```powershell
cd "C:\Users\Jibbran\Documents\GCP Project"
git add .
git commit -m "Trigger pipeline"
git push origin main
```

## 10. Approve and deploy

Go to **GitHub → Actions**.  
You will see:
1. Terraform fmt  
2. Terraform validate  
3. Terraform plan  
4. Manual approval  
5. Terraform apply

Approve when prompted.

## 11. Get your Load Balancer URL

After apply, check outputs:

```powershell
cd "C:\Users\Jibbran\Documents\GCP Project\infra"
terraform output
```

Open `load_balancer_url` in your browser.

## 12. Troubleshooting (common issues)

**Terraform: “terraform is not recognized”**  
- Reopen PowerShell or reinstall Terraform and add to PATH.

**Billing error (Compute Engine won’t enable)**  
- Link a billing account to your project, then rerun `terraform apply`.

**Permission denied**  
- Make sure you are logged in with the correct Google account.

**GitHub Actions authentication failed**  
- Check secrets: `WIF_PROVIDER`, `TF_SA_EMAIL`, `TF_STATE_BUCKET`.

## 13. Clean up (to avoid costs)

```powershell
cd "C:\Users\Jibbran\Documents\GCP Project\infra"
terraform destroy -var="project_id=YOUR_GCP_PROJECT_ID"
```

---

You now have a full DevOps-style automation pipeline on GCP. If you want HTTPS, custom domain, or autoscaling, I can add that next.

