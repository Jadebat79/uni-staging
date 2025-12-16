variable "region" {
  description = "AWS Region to deploy to"
  default     = ""
}

variable "aws_account_id" {
  description = "The AWS Account ID where ECR resides"
  type        = string
  default = ""
}

variable "project_name" {
  description = "Name tag for resources"
  default     = ""
}

variable "domain_name" {
  description = "The root domain name (e.g., myproject.com)"
  type        = string
  default     = ""
}

variable "allowed_cidr" {
  description = "IP allowed to SSH (e.g., 203.0.113.5/32)"
  type        = string
  default     = ""
}

variable "github_repo_url" {
  description = "HTTPS URL of this infrastructure repository"
  type        = string
  default     = ""
  # Example: "https://github.com/jade/universal-staging.git"
}

variable "github_token" {
  description = "GitHub PAT to clone this repo on the server"
  type        = string
  sensitive   = true
  default     = ""
}