# --- 4. EC2 Instance ---
resource "aws_instance" "server" {
  ami                  = "ami-0ecb62995f68bb549" # Ubuntu 22.04 LTS (Update for your region!)
  instance_type        = "t3.small"
  iam_instance_profile = aws_iam_instance_profile.profile.name
  vpc_security_group_ids = [aws_security_group.sg.id]

  # Inject variables into the boot script
  user_data = templatefile("${path.module}/user_data.sh", {
    git_token    = var.github_token
    git_repo     = replace(var.github_repo_url, "https://", "")
    ecr_url      = "${var.aws_account_id}.dkr.ecr.${var.region}.amazonaws.com"
    project_name = var.project_name
    office_ip    = var.allowed_cidr  # Use same IP as SSH whitelist, or create separate variable
  })

  tags = { 
    Name = "${var.project_name}-box" 
    }
}

# --- 4. Elastic IP ---
resource "aws_eip" "lb" {
  instance = aws_instance.server.id
  domain   = "vpc"
}