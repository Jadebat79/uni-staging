variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key" { sensitive = true }
variable "region" { default = "" }
variable "compartment_ocid" {}

variable "project_name" { default = "universal-staging" }
variable "ssh_public_key" { 
  description = "OCI requires an SSH key for the 'ubuntu' user"
}

# --- Git & Networking ---
variable "github_repo_url" {}
variable "github_token" { sensitive = true }
variable "office_ip" { description = "CIDR for SSH access" }