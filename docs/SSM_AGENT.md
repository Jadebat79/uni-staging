# AWS SSM Agent Setup

## Overview

The EC2 instance uses AWS Systems Manager (SSM) Session Manager for secure access without SSH keys. This document explains the setup and requirements.

## Prerequisites

### IAM Role Requirements

The EC2 instance must have an IAM role with the following policies attached:

1. **AmazonSSMManagedInstanceCore** (AWS Managed Policy)
   - Allows SSM agent to communicate with Systems Manager
   - Required for Session Manager access

2. **AmazonEC2ContainerRegistryReadOnly** (AWS Managed Policy)
   - Allows pulling Docker images from ECR
   - Required for container deployments

3. **Custom SSM Parameter Read Policy** (`ssm-policy.tf`)
   - Allows reading secrets from SSM Parameter Store
   - Path: `/staging/*`

4. **Custom CloudWatch Logs Policy** (`cloudwatch-policy.tf`)
   - Allows sending logs to CloudWatch Logs
   - Log group: `/staging/containers`

## IAM Role Configuration

The IAM role is defined in `infra/aws/role.tf` (currently commented out). To enable:

1. Uncomment the IAM role resources in `role.tf`
2. Ensure the role is attached to the EC2 instance in `compute.tf`
3. The role will automatically include all required policies

## SSM Agent Installation

The Ansible playbook automatically:
- Checks if SSM agent is installed
- Installs it if missing (Ubuntu package: `amazon-ssm-agent`)
- Ensures the service is running and enabled

Location: `config/ansible/playbook.yml` lines 133-145

## Accessing the Instance

### Via AWS Console:
1. Go to EC2 → Instances
2. Select the instance
3. Click "Connect" → "Session Manager"
4. Click "Connect"

### Via AWS CLI:
```bash
aws ssm start-session --target i-<instance-id>
```

### Via Terraform Output:
```bash
# Get instance ID
terraform output instance_id

# Connect
aws ssm start-session --target $(terraform output -raw instance_id)
```

## Security Benefits

- **No SSH keys required** - Eliminates key management overhead
- **No open SSH port** - Port 22 is closed in firewall
- **Audit trail** - All sessions are logged in CloudTrail
- **IAM-based access** - Control access via IAM policies
- **Encrypted** - All sessions are encrypted

## Troubleshooting

### SSM Agent Not Running

```bash
# Check status
sudo systemctl status amazon-ssm-agent

# Start if stopped
sudo systemctl start amazon-ssm-agent
sudo systemctl enable amazon-ssm-agent
```

### Cannot Connect via Session Manager

1. **Check IAM Role:**
   - Verify instance has IAM role attached
   - Verify role has `AmazonSSMManagedInstanceCore` policy

2. **Check SSM Agent:**
   - Verify agent is installed: `dpkg -l | grep ssm`
   - Verify agent is running: `sudo systemctl status amazon-ssm-agent`

3. **Check Instance Tags:**
   - Ensure instance has proper tags for identification

4. **Check Region:**
   - Ensure you're connecting from the same region as the instance

### SSM Agent Logs

```bash
# View agent logs
sudo tail -f /var/log/amazon/ssm/amazon-ssm-agent.log
```

## Documentation

- [AWS Systems Manager Session Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html)
- [SSM Agent Installation](https://docs.aws.amazon.com/systems-manager/latest/userguide/ssm-agent.html)

