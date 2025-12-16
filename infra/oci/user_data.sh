#!/bin/bash
set -e

# 1. Fix OCI Ubuntu Firewall (Critical!)
# Allow HTTP/HTTPS by flushing default restricted rules
iptables -F
netfilter-persistent save

# 2. Install Tools
apt-get update
apt-get install -y ansible git python3-pip

# Install OCI CLI (if not present) and setup Python SDK for Ansible
pip3 install oci

# 3. Clone Repo
git clone https://${git_token}@${git_repo} /opt/${project_name}

# 4. Fetch Secrets (Using Instance Principal)
# Note: You must update this OCID with your actual Vault Secret ID 
# or pass it as a variable if you automated secret creation.
# For this example, we assume you fetch via CLI using --auth instance_principal

# Create dir
mkdir -p /opt/${project_name}/orchestration/env

echo "Fetching secrets from OCI Vault..."
# This part is trickier in shell than AWS. 
# Usually, we recommend using the Ansible OCI collection to do this step.
# For now, we will create a placeholder. In OCI, the best practice 
# is to use the 'oci_secrets_secret_bundle' data source in Ansible.

# 5. Run Ansible
cd /opt/${project_name}/config/ansible
ansible-galaxy collection install -r requirements.yml

cat <<EOF > /etc/infra_config.env
ECR_URL=${ecr_url}
PROJECT_ROOT=/opt/${project_name}
OCI_AUTH_TYPE=instance_principal
OCI_SECRET_ID=<PASTE_YOUR_REAL_OCID_HERE_OR_PASS_VIA_VAR>
EOF

ansible-playbook playbook.yml