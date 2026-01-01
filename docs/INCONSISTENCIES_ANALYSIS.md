# Inconsistencies Analysis Report

## Overview
This document outlines all inconsistencies found in the codebase based on your requirements:
- Two separate Ansible playbooks (one for AWS, one for OCI)
- User data should handle environment differences
- Use GHCR (GitHub Container Registry) for both environments (not ECR/OCIR)
- AWS should allow SSH access (no SSM needed)

---

## 1. PLAYBOOK STRUCTURE INCONSISTENCIES

### Current State:
- **`playbook.yml`**: Universal playbook that tries to detect AWS vs OCI using registry URL patterns
- **`playbook-oci.yml`**: Separate OCI-specific playbook

### Issues:
1. **`playbook.yml`** (lines 14-26) detects provider by checking if `ECR_URL` contains `dkr.ecr` (AWS) or `ocir.io` (OCI)
   - This logic won't work with GHCR since GHCR URLs are `ghcr.io`
   - The playbook has conditional logic for both AWS and OCI throughout

2. **`playbook-oci.yml`** exists but is incomplete compared to `playbook.yml`
   - Missing many system setup tasks (SSH hardening, firewall, deploy user, etc.)
   - Only has basic Docker install and OCI secrets

### Required Changes:
- Split `playbook.yml` into two separate playbooks:
  - `playbook-aws.yml` - AWS-specific
  - `playbook-oci.yml` - OCI-specific (needs to be expanded)
- Remove universal detection logic
- Each playbook should be self-contained for its environment

---

## 2. REGISTRY CONFIGURATION INCONSISTENCIES

### Current State:

#### AWS:
- **`infra/aws/compute.tf`** (line 12): Passes `ecr_url = "${var.aws_account_id}.dkr.ecr.${var.region}.amazonaws.com"`
- **`infra/aws/user_data.sh`** (line 15): Writes `ECR_URL=${ecr_url}` to config
- **`playbook.yml`** (lines 432-439): Logs into ECR using AWS CLI
- **`infra/aws/role.tf`** (lines 30-33): Has `AmazonEC2ContainerRegistryReadOnly` IAM policy (not needed for GHCR)

#### OCI:
- **`infra/oci/compute.tf`** (line 30): Passes `ecr_url = "${var.region}.ocir.io/${data.oci_objectstorage_namespace.ns.namespace}"`
- **`playbook-oci.yml`** (lines 9-11, 114-116): Expects `REGISTRY_URL`, `REGISTRY_USER`, `REGISTRY_TOKEN` and logs into OCIR
- **`infra/oci/user_data.sh`**: Doesn't set registry variables

#### Docker Compose:
- **`orchestration/docker-compose.yml`**: Already uses GHCR images (e.g., `ghcr.io/jadebat79/be-hikegh:...`)

### Issues:
1. Terraform passes ECR/OCIR URLs but should pass GHCR URL (`ghcr.io`)
2. User data scripts don't set up GHCR authentication
3. Playbooks try to login to ECR/OCIR instead of GHCR
4. AWS IAM role has ECR permissions that won't be needed
5. OCI playbook expects OCIR credentials but should expect GHCR credentials

### Required Changes:
- Add `ghcr_token` variable to both AWS and OCI Terraform configs
- Update user data scripts to write GHCR token to config file
- Update playbooks to login to GHCR instead of ECR/OCIR
- Remove ECR IAM policy from AWS role
- GHCR login: `echo $GHCR_TOKEN | docker login ghcr.io -u USERNAME --password-stdin`

---

## 3. SSH CONFIGURATION INCONSISTENCIES

### Current State:

#### AWS:
- **`infra/aws/sg.tf`** (lines 19-25): Security group ALLOWS SSH (port 22) from `allowed_cidr`
- **`playbook.yml`** (lines 178-189): UFW rule for SSH is ONLY applied when `is_oci | bool`
  - Comment says: "Note: On AWS, SSH (22) remains blocked at UFW level; use SSM."
- **`playbook.yml`** (lines 212-285): SSM agent installation code is commented out but present

#### OCI:
- **`infra/oci/network.tf`** (lines 40-45): Security list ALLOWS SSH from `0.0.0.0/0`
- **`playbook.yml`** (lines 178-183): UFW allows SSH when `is_oci | bool`

### Issues:
1. AWS security group allows SSH, but playbook blocks it in UFW
2. SSM-related code is commented out but still present (should be removed if not using SSM)
3. AWS IAM role has SSM policies that won't be needed

### Required Changes:
- Update AWS playbook to allow SSH in UFW (same as OCI)
- Remove SSM agent installation code from playbooks
- Remove SSM-related IAM policies from AWS role (keep only what's needed for secrets)

---

## 4. USER DATA SCRIPT INCONSISTENCIES

### Current State:

#### AWS (`infra/aws/user_data.sh`):
- Very simple: installs ansible, clones repo, writes config, runs `playbook.yml`
- Writes `ECR_URL` (should be GHCR)
- Doesn't set up GHCR authentication
- Doesn't install Python venv (unlike OCI)

#### OCI (`infra/oci/user_data.sh`):
- More complex: firewall fix, Python venv setup, OCI CLI install
- Doesn't write registry config at all
- Runs `playbook-oci.yml` (correct)
- Sets up OCI-specific config

### Issues:
1. AWS user data is too simple and doesn't match OCI's setup
2. Neither script sets up GHCR authentication
3. AWS script passes wrong registry URL
4. Inconsistent approach between environments

### Required Changes:
- Both user data scripts should:
  - Set up GHCR token in config file
  - Install necessary dependencies consistently
  - Pass correct registry information
- AWS user data should be more robust (similar to OCI)
- Both should write `GHCR_TOKEN` and `GHCR_USERNAME` to `/etc/infra_config.env`

---

## 5. TERRAFORM CONFIGURATION INCONSISTENCIES

### Current State:

#### AWS:
- **`infra/aws/compute.tf`**: Passes `ecr_url` (ECR URL) to user_data
- **`infra/aws/variables.tf`**: Has `aws_account_id` variable (for ECR)
- **`infra/aws/role.tf`**: Has ECR read policy

#### OCI:
- **`infra/oci/compute.tf`**: Passes `ecr_url` (OCIR URL) to user_data
- **`infra/oci/compute.tf`**: Uses different variable names (`GIT_TOKEN`, `GIT_REPO`, `PROJECT_NAME` vs `git_token`, `git_repo`, `project_name`)

### Issues:
1. Both pass wrong registry URLs
2. Variable naming inconsistency between AWS and OCI
3. AWS has ECR-specific variables that aren't needed

### Required Changes:
- Add `ghcr_token` variable to both AWS and OCI
- Add `ghcr_username` variable (or hardcode if it's always the same)
- Remove ECR-specific variables from AWS
- Standardize variable names between environments
- Pass GHCR credentials to user_data templates

---

## 6. SECRETS MANAGEMENT INCONSISTENCIES

### Current State:
- **`playbook.yml`**: Fetches secrets from SSM (AWS) or OCI Vault (OCI)
- **`playbook-oci.yml`**: Only fetches from OCI Vault

### Issues:
- This part seems correct - each environment uses its own secret store
- But need to verify both playbooks have complete secret fetching logic

---

## 7. SUMMARY OF REQUIRED CHANGES

### High Priority:
1. ✅ Split `playbook.yml` into `playbook-aws.yml` and `playbook-oci.yml`
2. ✅ Update both playbooks to login to GHCR instead of ECR/OCIR
3. ✅ Update AWS playbook to allow SSH in UFW
4. ✅ Remove SSM-related code from playbooks
5. ✅ Remove ECR IAM policy from AWS role
6. ✅ Add GHCR token/username variables to Terraform
7. ✅ Update user_data scripts to set up GHCR authentication
8. ✅ Standardize variable naming between AWS and OCI

### Medium Priority:
9. ✅ Expand `playbook-oci.yml` to include all system setup tasks (currently missing SSH hardening, firewall, deploy user, etc.)
10. ✅ Make AWS user_data script more robust (similar to OCI)

### Low Priority:
11. ✅ Clean up commented SSM code
12. ✅ Update documentation to reflect GHCR usage

---

## 8. FILES THAT NEED CHANGES

### Ansible:
- `config/ansible/playbook.yml` → Split into `playbook-aws.yml` and expand `playbook-oci.yml`
- `config/ansible/playbook-oci.yml` → Expand with missing tasks

### Terraform - AWS:
- `infra/aws/compute.tf` → Update user_data template to pass GHCR credentials
- `infra/aws/user_data.sh` → Add GHCR setup, improve robustness
- `infra/aws/variables.tf` → Add `ghcr_token`, remove `aws_account_id`
- `infra/aws/role.tf` → Remove ECR policy, remove SSM policies if not needed

### Terraform - OCI:
- `infra/oci/compute.tf` → Update user_data template to pass GHCR credentials
- `infra/oci/user_data.sh` → Add GHCR setup
- `infra/oci/variables.tf` → Add `ghcr_token`, standardize variable names

---

## 9. GHCR AUTHENTICATION REQUIREMENTS

For GitHub Container Registry, you need:
- **Token**: GitHub Personal Access Token (PAT) with `read:packages` permission
- **Username**: Your GitHub username
- **Registry URL**: `ghcr.io`

Login command:
```bash
echo $GHCR_TOKEN | docker login ghcr.io -u $GHCR_USERNAME --password-stdin
```

This should be done in the Ansible playbooks, not in user_data (to avoid storing credentials in user_data script).

