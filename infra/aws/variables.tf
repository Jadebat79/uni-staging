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
  description = "HTTPS URL of this infrastructure repository (GitHub or Bitbucket)"
  type        = string
  default     = ""
  # Example GitHub: "https://github.com/jade/staging.git"
  # Example Bitbucket: "https://bitbucket.org/workspace/staging.git"
}

variable "github_token" {
  description = "GitHub PAT or Bitbucket App Password to clone this repo on the server"
  type        = string
  sensitive   = true
  default     = ""
  # For GitHub: Use Personal Access Token (PAT)
  # For Bitbucket: Use App Password
}

variable "office_ip" {
  description = "Office IP address for Caddy IP whitelist (e.g., 203.0.113.5)"
  type        = string
  default     = ""
}

variable "enable_disk_alarm" {
  description = "Enable CloudWatch alarm for disk usage > 80%"
  type        = bool
  default     = true
}