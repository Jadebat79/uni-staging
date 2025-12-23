# Using This Setup with Bitbucket

This guide explains how to clone this repository and use it with Bitbucket VCS instead of GitHub.

## Overview

This repository is designed to work with **both GitHub and Bitbucket**. The setup is VCS-agnostic - you can use it with either platform by simply cloning the repository and configuring the appropriate CI/CD pipeline.

## Quick Start: Clone to Bitbucket

### Step 1: Clone Repository to Bitbucket

1. **Create a new repository in Bitbucket:**
   - Go to your Bitbucket workspace
   - Click "Create repository"
   - Name it (e.g., `staging-infrastructure`)

2. **Clone this repository locally:**
   ```bash
   git clone <original-github-repo-url>
   cd uni-staging
   ```

3. **Change remote to Bitbucket:**
   ```bash
   git remote set-url origin <your-bitbucket-repo-url>
   # Example: https://bitbucket.org/your-workspace/staging-infrastructure.git
   ```

4. **Push to Bitbucket:**
   ```bash
   git push -u origin main
   ```

### Step 2: Configure Bitbucket Pipeline

The `bitbucket-pipelines.yml` file is already included in the repository. Bitbucket will automatically detect and use it.

**Set Repository Variables:**
Go to **Repository Settings > Pipelines > Repository variables** and add:

| Variable | Description | Example |
|----------|-------------|---------|
| `AWS_ACCESS_KEY_ID` | AWS access key for SSM | `AKIA...` |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key | `secret...` |
| `AWS_REGION` | AWS region | `us-east-1` |
| `EC2_INSTANCE_ID` | EC2 instance ID | `i-0123456789abcdef0` |
| `PROJECT_NAME` | Project name | `staging` |

### Step 3: Update Terraform Variables

When setting up Terraform (Cloud or local), use your **Bitbucket** repository URL:

**Terraform Variables:**
```hcl
github_repo_url = "https://bitbucket.org/your-workspace/staging-infrastructure.git"
github_token    = "<your-bitbucket-app-password>"
```

**Note:** 
- Despite the variable name `github_repo_url`, it works with both GitHub and Bitbucket URLs
- For `github_token`, use a **Bitbucket App Password** (not a GitHub PAT)

### Step 4: Create Bitbucket App Password

1. Go to **Bitbucket Settings > Personal settings > App passwords**
2. Click "Create app password"
3. Give it a name (e.g., "Terraform Staging")
4. Select permissions: **Repositories: Read**
5. Copy the generated password
6. Use this password as `github_token` in Terraform

## How It Works

### Repository Structure

The repository structure remains the same regardless of VCS:

```
uni-staging/
├── bitbucket-pipelines.yml    # Bitbucket CI/CD (already included)
├── infra/                      # Terraform infrastructure
├── config/                     # Ansible configuration
├── orchestration/              # Docker Compose
└── docs/                       # Documentation
```

### CI/CD Pipeline

- **Bitbucket:** Uses `bitbucket-pipelines.yml` (already in repo)
- **GitHub:** Would use `.github/workflows/` (not included, but can be added)

Both pipelines do the same thing:
1. Detect changes to `orchestration/` directory
2. Send SSM command to EC2 instance
3. Server pulls latest code and updates services

### Variable Names

The Terraform variables use `github_*` naming for historical reasons, but they work with both:

- `github_repo_url` - Accepts both GitHub and Bitbucket URLs
- `github_token` - Accepts both GitHub PATs and Bitbucket App Passwords

This maintains backward compatibility while supporting both VCS platforms.

## Differences: GitHub vs Bitbucket

| Feature | GitHub | Bitbucket |
|---------|--------|-----------|
| **CI/CD** | GitHub Actions | Bitbucket Pipelines |
| **Config File** | `.github/workflows/` | `bitbucket-pipelines.yml` |
| **Authentication** | Personal Access Token (PAT) | App Password |
| **Variables** | Repository Secrets | Repository Variables |
| **Pipeline Detection** | Automatic | Automatic |

## Testing the Setup

After cloning to Bitbucket:

1. **Verify pipeline file exists:**
   ```bash
   ls -la bitbucket-pipelines.yml
   ```

2. **Make a test change:**
   ```bash
   # Edit a file in orchestration/
   echo "# Test" >> orchestration/docker-compose.yml
   git add orchestration/docker-compose.yml
   git commit -m "Test pipeline"
   git push origin main
   ```

3. **Check Bitbucket Pipelines:**
   - Go to your Bitbucket repository
   - Click "Pipelines" tab
   - Verify the pipeline runs successfully

## Troubleshooting

### Pipeline Not Running

- **Check:** Is `bitbucket-pipelines.yml` in the repository root?
- **Check:** Are you pushing to the `main` branch? (Pipeline triggers on `main`)
- **Check:** Do you have Pipelines enabled in repository settings?

### Authentication Errors

- **Bitbucket App Password:** Ensure it has "Repositories: Read" permission
- **Terraform:** Verify `github_token` is set correctly (use App Password, not account password)
- **SSM:** Verify AWS credentials are correct in Bitbucket repository variables

### Repository URL Format

**Correct Bitbucket URL formats:**
```
https://bitbucket.org/workspace/repo-name.git
https://username@bitbucket.org/workspace/repo-name.git
```

**Incorrect:**
```
git@bitbucket.org:workspace/repo-name.git  # SSH format (not supported in user_data.sh)
```

## Summary

✅ **Clone this repo to Bitbucket** - Works immediately  
✅ **Pipeline file included** - `bitbucket-pipelines.yml` ready to use  
✅ **Same structure** - No code changes needed  
✅ **Just configure variables** - Set Bitbucket repository variables and Terraform variables  

The setup is VCS-agnostic and works seamlessly with both GitHub and Bitbucket!

