# output "public_ip" {
#   value = aws_eip.lb.public_ip
# }

# output "ssm_role_arn" {
#   description = "Add this to your App Repo Secrets (AWS_ROLE_ARN)"
#   value       = aws_iam_role.ssm_role.arn
# }

# output "ecr_registry_url" {
#   description = "The base URL for your Docker images"
#   value       = split("/", aws_ecr_repository.app1.repository_url)[0]
# }