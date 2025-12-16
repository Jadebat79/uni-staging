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
1.  Create a Workspace named `universal-staging-aws` in Terraform Cloud.
2.  Connect it to this GitHub repository.
3.  **Important:** Set the "Terraform Working Directory" to `infra/aws`.
4.  Configure the following **Variables** in the TFC UI:

| Key | Type | Description |
| :--- | :--- | :--- |
| `AWS_ACCESS_KEY_ID` | Environment | AWS Credentials for Terraform |
| `AWS_SECRET_ACCESS_KEY` | Environment | AWS Credentials for Terraform |
| `region` | Terraform | AWS Region (e.g., `us-east-1`) |
| `aws_account_id` | Terraform | Your AWS Account ID (for ECR URLs) |
| `project_name` | Terraform | Resource prefix (default: `universal-staging`) |
| `domain_name` | Terraform | Root domain (e.g., `example.com`) |
| `allowed_cidr` | Terraform | Your Office IP for SSH fallback (e.g., `8.8.8.8/32`) |
| `github_token` | Terraform | PAT to clone this repo on the server |
| `github_repo_url` | Terraform | HTTPS URL of this repo |

### 2. Secrets Management (Crucial)
We do **not** store `.env` files in Git. You must upload application secrets to AWS SSM Parameter Store manually before deployment.

Run this locally for each app:
```bash
# Upload HikeGH Backend Secrets
aws ssm put-parameter \
    --name "/universal-staging/hikegh/env" \
    --description "Production secrets for HikeGH" \
    --value "$(cat path/to/local/hikegh.env)" \
    --type "SecureString" \
    --overwrite