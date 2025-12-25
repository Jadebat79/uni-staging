#!/bin/bash
set -e

echo ">>> Starting Manual Setup for ${PROJECT_NAME}..."

# 1. Fix OCI Ubuntu Firewall (Critical!)
# OCI Ubuntu images block HTTP by default. We flush rules to allow traffic.
echo ">>> Configuring Firewall..."
apt-get update
# Ensure netfilter-persistent is actually installed before trying to save
apt-get install -y iptables-persistent netfilter-persistent
iptables -F
netfilter-persistent save

# 2. Install System Dependencies
echo ">>> Installing System Tools..."
# We added python3-venv here
apt-get install -y git python3-pip python3-venv unzip

# 3. Setup Virtual Environment (The Fix for PEP 668)
echo ">>> Setting up Python Virtual Environment..."
# Create the environment in /opt/ansible-venv
python3 -m venv /opt/ansible-venv

# Upgrade pip inside the venv
/opt/ansible-venv/bin/pip install --upgrade pip

# Install Ansible and OCI SDK inside this isolated environment
# This ensures Ansible can definitely see the OCI library
/opt/ansible-venv/bin/pip install ansible oci

# 4. Install OCI CLI (Optional, but good for debugging)
if [ ! -f "/root/bin/oci" ]; then
    echo ">>> Installing OCI CLI..."
    bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)" -- --accept-all-defaults
fi

# 5. Clone Repo
echo ">>> Cloning Repository..."
rm -rf /opt/${PROJECT_NAME}
git clone https://${GIT_TOKEN}@${GIT_REPO} /opt/${PROJECT_NAME}

# 6. Setup Secrets & Config
echo ">>> Configuring Environment..."
mkdir -p /opt/${PROJECT_NAME}/orchestration/env

# Write the config file
cat <<EOF > /etc/infra_config.env
PROJECT_ROOT=/opt/${PROJECT_NAME}
OCI_AUTH_TYPE=instance_principal
OCI_REGION=${OCI_REGION}
OCI_TENANCY_OCID=${TENANCY_OCID}
OCI_COMPARTMENT_OCID=${COMPARTMENT_OCID}
OCI_SECRET_ID=${SECRET_OCID}
EOF

# 7. Run Ansible
echo ">>> Running Ansible Playbook..."
cd /opt/${PROJECT_NAME}/config/ansible

# Use the VENV executable to install collections
/opt/ansible-venv/bin/ansible-galaxy collection install -r requirements.yml || /opt/ansible-venv/bin/ansible-galaxy collection install oracle.oci

# Use the VENV executable to run the playbook
/opt/ansible-venv/bin/ansible-playbook playbook.yml

echo ">>> Setup Complete!"