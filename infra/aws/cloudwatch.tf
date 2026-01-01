# CloudWatch Log Group for container logs
# Retention: 3 days as per requirements
resource "aws_cloudwatch_log_group" "container_logs" {
  name              = "/staging/containers"
  retention_in_days = 3

  tags = {
    Name        = "${var.project_name}-container-logs"
    Environment = "staging"
    ManagedBy   = "Terraform"
  }
}

# Optional: CloudWatch Alarm for disk usage > 80%
# This prevents the staging VM from running out of disk space
# Note: Requires CloudWatch Agent to be installed on the instance
# Uncomment and configure when instance is active
# resource "aws_cloudwatch_metric_alarm" "disk_usage" {
#   count = var.enable_disk_alarm ? 1 : 0
#
#   alarm_name          = "${var.project_name}-disk-usage-high"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = "2"
#   metric_name         = "disk_used_percent"
#   namespace           = "CWAgent"
#   period              = "300"
#   statistic           = "Average"
#   threshold           = "80"
#   alarm_description   = "This metric monitors disk usage on staging VM"
#   treat_missing_data  = "breaching"
#
#   dimensions = {
#     device     = "/dev/xvda1"
#     fstype     = "ext4"
#     path       = "/"
#     InstanceId = aws_instance.server.id
#   }
#
#   tags = {
#     Name        = "${var.project_name}-disk-alarm"
#     Environment = "staging"
#   }
# }

