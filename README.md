# Universal Staging Infrastructure

This repository contains the **Infrastructure as Code (IaC)** and **Configuration Management** for the Universal Staging Environment.

It implements a **Cloud Agnostic** architecture using a hybrid of Terraform (Infrastructure), Ansible (Configuration), and Docker Compose (Orchestration).

## 🏗 Architecture Overview

* **Compute:** Single AWS EC2 Instance (`t3a.medium` recommended).
* **Networking:** Elastic IP + Route53.
* **Security:** IAM Roles + SSM (No SSH Key Pairs used).
* **Orchestration:** Docker Compose managing microservices.
* **Routing:** Caddy (Automatic HTTPS & Reverse Proxy).
* **Secrets:** AWS SSM Parameter Store.

---

## 🚀 Getting Started

### Prerequisites
* [Terraform CLI](https://developer.hashicorp.com/terraform/downloads) (v1.3+)
* [AWS CLI v2](https://aws.amazon.com/cli/)
* **Terraform Cloud Account** (Free Tier is sufficient)

### 1. Terraform Cloud Setup
1.  Create a Workspace named `staging-aws` in Terraform Cloud.
2.  Connect it to this repository.
3.  **Important:** Set the "Terraform Working Directory" to `infra/aws`.
4.  Configure the following **Variables** in the TFC UI:

| Key | Type | Description |
| :--- | :--- | :--- |
| `AWS_ACCESS_KEY_ID` | Environment | AWS Credentials for Terraform |
| `AWS_SECRET_ACCESS_KEY` | Environment | AWS Credentials for Terraform |
| `region` | Terraform | AWS Region (e.g., `us-east-1`) |
| `aws_account_id` | Terraform | Your AWS Account ID (for ECR URLs) |
| `project_name` | Terraform | Resource prefix (default: `staging`) |
| `domain_name` | Terraform | Root domain (e.g., `example.com`) |
| `allowed_cidr` | Terraform | Your Office IP for SSH fallback (e.g., `8.8.8.8/32`) |
| `github_token` | Terraform | GitHub PAT or Bitbucket App Password to clone this repo |
| `github_repo_url` | Terraform | HTTPS URL of this repo (GitHub or Bitbucket) |

### 2. CI/CD Pipeline Setup

#### For GitHub Actions:
The repository includes `.github/workflows/` configuration (if applicable).

#### For Bitbucket Pipelines:
1. Copy `bitbucket-pipelines.yml` to your Bitbucket repository root
2. Set these in **Bitbucket Repository Settings > Pipelines > Repository variables**:

| Variable | Description |
|----------|-------------|
| `AWS_ACCESS_KEY_ID` | AWS access key for SSM |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key |
| `AWS_REGION` | AWS region (e.g., `us-east-1`) |
| `EC2_INSTANCE_ID` | EC2 instance ID |
| `PROJECT_NAME` | Project name (default: `staging`) |

**Note:** To use this setup with Bitbucket, simply clone this repository to Bitbucket and configure the pipeline variables above.

### 3. Secrets Management (Crucial)
We do **not** store `.env` files in Git. You must upload application secrets to AWS SSM Parameter Store manually before deployment.

Run this locally for each app:
```bash
# Upload HikeGH Backend Secrets
aws ssm put-parameter \
    --name "/staging/hikegh/env" \
    --description "Staging secrets for HikeGH" \
    --value "$(cat path/to/local/hikegh.env)" \
    --type "SecureString" \
    --overwrite
```

---

## 📚 Documentation

For complete documentation, see: **[docs/COMPLETE_DOCUMENTATION.md](docs/COMPLETE_DOCUMENTATION.md)**

This single file contains all documentation including:
- Architecture overview
- Getting started guide
- Secrets management workflow
- Automated updates
- Deploy user configuration
- SSM agent setup
- Task completion status
- Troubleshooting guide

### Using with Bitbucket

This repository works with **both GitHub and Bitbucket**. To use it with Bitbucket:

1. Clone this repository to Bitbucket
2. The `bitbucket-pipelines.yml` file is already included
3. Configure Bitbucket repository variables (see [docs/BITBUCKET_SETUP.md](docs/BITBUCKET_SETUP.md))

For detailed Bitbucket setup instructions, see: **[docs/BITBUCKET_SETUP.md](docs/BITBUCKET_SETUP.md)**