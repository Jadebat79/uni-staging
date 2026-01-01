variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key" { sensitive = true }
variable "region" { default = "" }
variable "compartment_ocid" {}

variable "project_name" { default = "staging" }
variable "ssh_public_key" { 
  description = "OCI requires an SSH key for the 'ubuntu' user"
}

# --- Git & Networking ---
variable "github_repo_url" {}
variable "github_token" { sensitive = true }
variable "office_ip" { 
  description = "Office IP address for Caddy IP whitelist (e.g., 203.0.113.5)"
  default     = ""
}
variable "domain_name" {
  description = "The root domain name (e.g., myproject.com)"
  type        = string
  default     = "teamcanvas.site"
}

# --- Container Registry ---
variable "ghcr_token" {
  description = "GitHub Personal Access Token with read:packages permission for GHCR"
  type        = string
  sensitive   = true
  default     = ""
}
variable "ghcr_username" {
  description = "GitHub username for GHCR authentication"
  type        = string
  default     = ""
}