#!/bin/bash
set -e

# 1. Install System Dependencies
apt-get update
apt-get install -y ansible git

# 2. Clone the Infrastructure Repository
# We inject the token into the URL to authenticate private clone
git clone https://${git_token}@${git_repo} /opt/${project_name}

# 3. Export Terraform Variables for Ansible
# We write these to a temp file so Ansible can read them
cat <<EOF > /etc/infra_config.env
ECR_URL=${ecr_url}
PROJECT_ROOT=/opt/${project_name}
# Generate a random initial DB password
ROOT_DB_PASS=$(openssl rand -hex 16)
EOF

# 4. Run Ansible
cd /opt/${project_name}/config/ansible
ansible-playbook playbook.yml