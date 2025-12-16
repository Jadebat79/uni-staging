# # --- 3. ECR Repositories (Add more apps here) ---
# resource "aws_ecr_repository" "app1" {
#   name         = "${var.project_name}/app1"
#   force_delete = true
# }

# resource "aws_ecr_repository" "app2" {
#   name         = "${var.project_name}/app2"
#   force_delete = true
# }