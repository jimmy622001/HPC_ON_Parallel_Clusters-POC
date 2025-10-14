#!/bin/bash

# Update system and install dependencies
sudo yum update -y
sudo yum install -y git gcc gcc-c++ make patch openssl-devel zlib-devel bzip2 \
  sqlite-devel libffi-devel readline-devel bison libyaml-devel \
  httpd httpd-devel httpd-manual httpd-tools mod_ssl mod_auth_kerb \
  mod_authnz_pam mod_authnz_ldap mod_session mod_lua \
  mariadb-devel nfs-utils amazon-efs-utils

# Install Node.js and Yarn
curl -sL https://rpm.nodesource.com/setup_16.x | sudo bash -
sudo yum install -y nodejs
sudo npm install -g yarn

# Install Ruby and RubyGems
sudo yum install -y ruby ruby-devel rubygems
sudo gem install bundler

# Install and configure EFS
sudo mkdir -p /shared
# Add retry logic for EFS mount
MAX_RETRIES=5
COUNTER=0
while [ $COUNTER -lt $MAX_RETRIES ]; do
    echo "Attempting to mount EFS (Attempt $((COUNTER+1))/$MAX_RETRIES)..."
    if sudo mount -t efs -o tls ${efs_id}:/ /shared; then
        echo "EFS mounted successfully"
        echo "${efs_id}:/ /shared efs _netdev,tls,iam 0 0" | sudo tee -a /etc/fstab
        break
    else
        echo "Failed to mount EFS, retrying in 10 seconds..."
        sleep 10
        COUNTER=$((COUNTER+1))
    fi
done

if [ $COUNTER -eq $MAX_RETRIES ]; then
    echo "ERROR: Failed to mount EFS after $MAX_RETRIES attempts"
    exit 1
fi

# Create necessary directories
sudo mkdir -p /etc/ood/config/apps/sys
sudo mkdir -p /etc/ood/config/apps/dashboard
sudo mkdir -p /var/www/ood/apps/sys
sudo mkdir -p /var/www/ood/apps/usr

# Install Open OnDemand
sudo yum install -y https://yum.osc.edu/ondemand/latest/ondemand-release-web-latest-1-6.noarch.rpm
sudo yum install -y ondemand

# Configure Open OnDemand
cat << EOF | sudo tee /etc/ood/config/ood_portal.yml
---
# ServerName: ${domain_name}
Port: '80'
SSLPort: '443'

# Database configuration
database:
  host: ${db_endpoint}
  username: ${db_username}
  password: ${db_password}
  database: ood
  adapter: mysql2
  encoding: utf8
  pool: 5
  timeout: 5000

# Add retry logic for database connection
MAX_DB_RETRIES=30
DB_RETRY_DELAY=10
DB_CONNECTED=0

for i in $(seq 1 $MAX_DB_RETRIES); do
    echo "Attempting to connect to database (Attempt $i/$MAX_DB_RETRIES)..."
    if mysql -h ${db_endpoint} -u ${db_username} -p${db_password} -e "SELECT 1" >/dev/null 2>&1; then
        echo "Successfully connected to database"
        DB_CONNECTED=1
        break
    else
        echo "Database not ready, retrying in $DB_RETRY_DELAY seconds..."
        sleep $DB_RETRY_DELAY
    fi
done

if [ $DB_CONNECTED -eq 0 ]; then
    echo "ERROR: Failed to connect to database after $MAX_DB_RETRIES attempts"
    exit 1
fi

# SSL Configuration
# ssl:
#   - 'SSLCertificateFile /etc/pki/tls/certs/ood.crt'
#   - 'SSLCertificateKeyFile /etc/pki/tls/private/ood.key'
#   - 'SSLCertificateChainFile /etc/pki/tls/certs/ood-chain.crt'

# Authentication
auth:
  - 'AuthType openid-connect'
  - 'OIDCProviderMetadataURL https://your-oidc-provider/.well-known/openid-configuration'
  - 'OIDCClientID your-client-id'
  - 'OIDCClientSecret your-client-secret'
  - 'OIDCRedirectURI /oidc'
  - 'OIDCScope "openid email profile"'
  - 'OIDCRemoteUserClaim email'
  - 'OIDCCryptoPassphrase your-crypto-passphrase'

# Database configuration
database:
  adapter: mysql2
  host: ${db_endpoint}
  database: ${db_name}
  username: ${db_username}
  password: ${db_password}
  encoding: utf8
  pool: 5
  timeout: 5000

# Pinned Apps
pinned_apps:
  - 'sys/shell'
  - 'sys/files'
  - 'sys/activejobs'
  - 'sys/dashboard'

# Customization
user_map_match: '^[^@]+$'
EOF

# Generate self-signed SSL certificate (replace with your own in production)
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/pki/tls/private/ood.key \
  -out /etc/pki/tls/certs/ood.crt \
  -subj "/C=US/ST=State/L=City/O=Organization/CN=${domain_name}"

# Update Apache configuration
sudo /opt/ood/ood-portal-generator/sbin/update_ood_portal

# Configure SELinux
sudo setsebool -P httpd_can_network_connect_db 1
sudo setsebool -P httpd_unified 1

# Enable and start services
sudo systemctl enable httpd
sudo systemctl start httpd
sudo systemctl enable ondemand
sudo systemctl start ondemand

# Install and configure Slurm
sudo yum install -y slurm slurm-devel slurm-slurmd slurm-slurmctld slurm-perlapi

# Configure Slurm (basic configuration - customize as needed)
sudo mkdir -p /etc/slurm
cat << EOF | sudo tee /etc/slurm/slurm.conf
# Basic Slurm configuration
ClusterName=ondemand
SlurmctldHost=localhost
MpiDefault=none
ProctrackType=proctrack/linuxproc
ReturnToService=1
SlurmctldPidFile=/var/run/slurmctld.pid
SlurmdPidFile=/var/run/slurmd.pid
SlurmdSpoolDir=/var/spool/slurmd
SlurmUser=slurm
SlurmdUser=root
StateSaveLocation=/var/spool/slurmctld
SwitchType=switch/none
TaskPlugin=task/affinity,task/cgroup

# Scheduler
SchedulerType=sched/backfill
SelectType=select/cons_tres
SelectTypeParameters=CR_Core_Memory

# Logging
SlurmctldLogFile=/var/log/slurmctld.log
SlurmdLogFile=/var/log/slurmd.log

# Nodes
NodeName=localhost NodeAddr=127.0.0.1 CPUs=2 RealMemory=1000 State=UNKNOWN
PartitionName=debug Nodes=ALL Default=YES MaxTime=INFINITE State=UP
EOF

# Start Slurm services
sudo systemctl enable slurmctld
sudo systemctl start slurmctld
sudo systemctl enable slurmd
sudo systemctl start slurmd

# Restart Open OnDemand
sudo systemctl restart httpd
sudo systemctl restart ondemand

echo "Open OnDemand installation and configuration completed!"
