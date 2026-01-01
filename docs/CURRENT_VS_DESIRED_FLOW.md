# Current vs Desired Flow

## CURRENT FLOW (Inconsistent)

### AWS Environment:
```
Terraform (compute.tf)
  ↓
  Passes: ecr_url = "ACCOUNT.dkr.ecr.REGION.amazonaws.com"
  ↓
user_data.sh
  ↓
  Writes: ECR_URL=ACCOUNT.dkr.ecr.REGION.amazonaws.com
  ↓
playbook.yml (Universal)
  ↓
  Detects: is_aws = true (because ECR_URL contains "dkr.ecr")
  ↓
  Tries to login to ECR using AWS CLI
  ↓
  Blocks SSH in UFW (even though security group allows it)
  ↓
  Has SSM code (commented out)
  ↓
docker-compose.yml
  ↓
  Uses: ghcr.io/jadebat79/... (GHCR images)
  ❌ CONFLICT: Playbook logged into ECR, but compose uses GHCR!
```

### OCI Environment:
```
Terraform (compute.tf)
  ↓
  Passes: ecr_url = "REGION.ocir.io/NAMESPACE"
  ↓
user_data.sh
  ↓
  Doesn't write registry config
  ↓
playbook-oci.yml (Separate)
  ↓
  Expects: REGISTRY_URL, REGISTRY_USER, REGISTRY_TOKEN
  ↓
  Tries to login to OCIR
  ↓
  Allows SSH in UFW
  ↓
docker-compose.yml
  ↓
  Uses: ghcr.io/jadebat79/... (GHCR images)
  ❌ CONFLICT: Playbook logged into OCIR, but compose uses GHCR!
```

---

## DESIRED FLOW (Consistent)

### AWS Environment:
```
Terraform (compute.tf)
  ↓
  Passes: ghcr_token, ghcr_username
  ↓
user_data.sh
  ↓
  Writes: GHCR_TOKEN=..., GHCR_USERNAME=...
  ↓
playbook-aws.yml (AWS-specific)
  ↓
  Logs into GHCR using token
  ↓
  Allows SSH in UFW (matches security group)
  ↓
  No SSM code
  ↓
docker-compose.yml
  ↓
  Uses: ghcr.io/jadebat79/... (GHCR images)
  ✅ CONSISTENT: Playbook logged into GHCR, compose uses GHCR!
```

### OCI Environment:
```
Terraform (compute.tf)
  ↓
  Passes: ghcr_token, ghcr_username
  ↓
user_data.sh
  ↓
  Writes: GHCR_TOKEN=..., GHCR_USERNAME=...
  ↓
playbook-oci.yml (OCI-specific)
  ↓
  Logs into GHCR using token
  ↓
  Allows SSH in UFW
  ↓
docker-compose.yml
  ↓
  Uses: ghcr.io/jadebat79/... (GHCR images)
  ✅ CONSISTENT: Playbook logged into GHCR, compose uses GHCR!
```

---

## KEY DIFFERENCES

| Aspect | Current (Wrong) | Desired (Correct) |
|--------|----------------|-------------------|
| **Registry** | ECR (AWS) / OCIR (OCI) | GHCR (both) |
| **Playbook Structure** | Universal with detection | Two separate playbooks |
| **AWS SSH** | Blocked in UFW | Allowed in UFW |
| **SSM** | Code present (commented) | Removed |
| **User Data** | Inconsistent between envs | Consistent approach |
| **Terraform Variables** | ECR-specific vars | GHCR token vars |

