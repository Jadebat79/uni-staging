// --- IAM Role and Policies for Staging EC2 Instance ---
//
// This file defines:
// - IAM Role for EC2 (with SSM + ECR access)
// - Inline policy for SSM Parameter Store reads
// - Inline policy for CloudWatch Logs (Fluent Bit)
// - Instance profile for attaching the role to EC2

resource "aws_iam_role" "ssm_role" {
  name = "${var.project_name}-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = "sts:AssumeRole"
        Principal = { Service = "ec2.amazonaws.com" }
      }
    ]
  })
}

// Attach AWS managed policies for SSM + ECR
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ecr_read" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

// Inline policy: allow EC2 instance to read parameters from SSM Parameter Store
resource "aws_iam_role_policy" "ssm_parameter_read" {
  name = "${var.project_name}-ssm-parameter-read"
  role = aws_iam_role.ssm_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath",
        ]
        Resource = [
          "arn:aws:ssm:${var.region}:*:parameter/${var.project_name}/*",
        ]
      }
    ]
  })
}

// Inline policy: allow EC2 instance to send logs to CloudWatch Logs
// Used by Fluent Bit to ship container logs without static credentials.
resource "aws_iam_role_policy" "cloudwatch_logs" {
  name = "${var.project_name}-cloudwatch-logs"
  role = aws_iam_role.ssm_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
        ]
        Resource = [
          "arn:aws:logs:${var.region}:*:log-group:/staging/*",
          "arn:aws:logs:${var.region}:*:log-group:/staging/*:*",
        ]
      }
    ]
  })
}

// Instance profile used by the EC2 instance
resource "aws_iam_instance_profile" "profile" {
  name = "${var.project_name}-profile"
  role = aws_iam_role.ssm_role.name
}