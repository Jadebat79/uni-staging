# File-by-File Breakdown

## ANSIBLE PLAYBOOKS

### `config/ansible/playbook.yml` (CURRENT - Universal)
**Current Behavior:**
- Detects AWS vs OCI by checking if `ECR_URL` contains `dkr.ecr` or `ocir.io`
- Has conditional logic for both environments
- Logs into ECR for AWS (lines 432-439)
- Blocks SSH in UFW for AWS (line 178-189)
- Has commented SSM code (lines 212-285)

**Should Be:**
- Renamed to `playbook-aws.yml` OR split into separate files
- AWS-specific only
- Login to GHCR instead of ECR
- Allow SSH in UFW
- Remove SSM code entirely

---

### `config/ansible/playbook-oci.yml` (CURRENT - Incomplete)
**Current Behavior:**
- OCI-specific playbook
- Only has basic Docker install and OCI secrets
- Missing: SSH hardening, firewall setup, deploy user creation, etc.
- Logs into OCIR (lines 114-116)
- Expects `REGISTRY_URL`, `REGISTRY_USER`, `REGISTRY_TOKEN` from config

**Should Be:**
- Complete OCI-specific playbook with all system setup tasks
- Login to GHCR instead of OCIR
- Expect `GHCR_TOKEN` and `GHCR_USERNAME` from config

---

## TERRAFORM - AWS

### `infra/aws/compute.tf`
**Current:**
```hcl
user_data = templatefile("${path.module}/user_data.sh", {
  ecr_url = "${var.aws_account_id}.dkr.ecr.${var.region}.amazonaws.com"
  ...
})
```

**Should Be:**
```hcl
user_data = templatefile("${path.module}/user_data.sh", {
  ghcr_token = var.ghcr_token
  ghcr_username = var.ghcr_username
  ...
})
```

---

### `infra/aws/user_data.sh`
**Current:**
- Simple script: install ansible, clone repo, write config, run playbook
- Writes `ECR_URL=${ecr_url}` to config
- Runs `playbook.yml`

**Should Be:**
- More robust (similar to OCI version)
- Write `GHCR_TOKEN` and `GHCR_USERNAME` to config
- Run `playbook-aws.yml` (or renamed playbook)

---

### `infra/aws/variables.tf`
**Current:**
- Has `aws_account_id` variable (for ECR)
- No GHCR variables

**Should Be:**
- Remove `aws_account_id`
- Add `ghcr_token` (sensitive)
- Add `ghcr_username`

---

### `infra/aws/role.tf`
**Current:**
- Has `AmazonEC2ContainerRegistryReadOnly` policy (line 30-33)
- Has SSM policies

**Should Be:**
- Remove ECR policy (not needed for GHCR)
- Keep SSM policies only if needed for secrets (or remove if using different secret store)

---

### `infra/aws/sg.tf`
**Current:**
- Allows SSH from `allowed_cidr` ✅ (This is correct)

**Should Be:**
- Keep as-is (already allows SSH)

---

## TERRAFORM - OCI

### `infra/oci/compute.tf`
**Current:**
```hcl
user_data = base64encode(templatefile("${path.module}/user_data.sh", {
  ecr_url = "${var.region}.ocir.io/${data.oci_objectstorage_namespace.ns.namespace}"
  ...
}))
```

**Should Be:**
```hcl
user_data = base64encode(templatefile("${path.module}/user_data.sh", {
  GIT_TOKEN = var.github_token
  GIT_REPO = replace(var.github_repo_url, "https://", "")
  PROJECT_NAME = var.project_name
  GHCR_TOKEN = var.ghcr_token
  GHCR_USERNAME = var.ghcr_username
  ...
}))
```

---

### `infra/oci/user_data.sh`
**Current:**
- Complex script with firewall fix, Python venv, OCI CLI
- Doesn't write registry config
- Runs `playbook-oci.yml`

**Should Be:**
- Add GHCR token/username to config file
- Keep everything else (it's good)

---

### `infra/oci/variables.tf`
**Current:**
- Uses uppercase: `GIT_TOKEN`, `GIT_REPO`, `PROJECT_NAME` (inconsistent with AWS)
- No GHCR variables

**Should Be:**
- Standardize to lowercase (or keep uppercase, but be consistent)
- Add `ghcr_token` (sensitive)
- Add `ghcr_username`

---

## DOCKER COMPOSE

### `orchestration/docker-compose.yml`
**Current:**
- Already uses GHCR images ✅ (This is correct!)

**Should Be:**
- Keep as-is (no changes needed)

---

## SUMMARY CHECKLIST

### Ansible:
- [ ] Split `playbook.yml` into `playbook-aws.yml` and `playbook-oci.yml`
- [ ] Update AWS playbook: GHCR login, allow SSH, remove SSM
- [ ] Expand OCI playbook: add missing system setup tasks
- [ ] Update OCI playbook: GHCR login instead of OCIR

### Terraform AWS:
- [ ] Update `compute.tf`: pass GHCR credentials
- [ ] Update `user_data.sh`: write GHCR config, improve robustness
- [ ] Update `variables.tf`: add GHCR vars, remove ECR vars
- [ ] Update `role.tf`: remove ECR policy

### Terraform OCI:
- [ ] Update `compute.tf`: pass GHCR credentials
- [ ] Update `user_data.sh`: write GHCR config
- [ ] Update `variables.tf`: add GHCR vars, standardize naming

### Documentation:
- [ ] Update README to mention GHCR instead of ECR/OCIR
- [ ] Update docs to remove SSM references (or keep if still using for secrets)

