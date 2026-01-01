#!/bin/bash
set -e

echo ">>> Starting AWS Setup for ${project_name}..."

# 1. Install System Dependencies
echo ">>> Installing System Tools..."
apt-get update
apt-get install -y ansible git python3-pip

# 2. Clone the Infrastructure Repository
echo ">>> Cloning Repository..."
# We inject the token into the URL to authenticate private clone
git clone https://${git_token}@${git_repo} /opt/${project_name}

# 3. Export Terraform Variables for Ansible
echo ">>> Configuring Environment..."
# We write these to a temp file so Ansible can read them
cat <<EOF > /etc/infra_config.env
PROJECT_ROOT=/opt/${project_name}
PROJECT_NAME=${project_name}
AWS_REGION=${aws_region}
DOMAIN_NAME=${domain_name}
OFFICE_IP=${office_ip}
ECR_URL=${ecr_url}
EOF

# 4. Run Ansible
echo ">>> Running Ansible Playbook..."
cd /opt/${project_name}/config/ansible
ansible-playbook playbook-aws.yml

echo ">>> Setup Complete!"