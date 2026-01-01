# --- 3. ECR Repositories (Add more apps here) ---
resource "aws_ecr_repository" "gpc_backend" {
  name         = "${var.project_name}/gpc_backend"
  force_delete = true
}

resource "aws_ecr_repository" "gpc_frontend" {
  name         = "${var.project_name}/gpc_frontend"
  force_delete = true
}