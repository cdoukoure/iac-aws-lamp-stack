#!/bin/bash -xe

# Log file
LOG_FILE="/var/log/bootstrap.log"
exec > >(tee -a ${LOG_FILE} | logger -t user-data -s 2>/dev/console) 2>&1

echo "[+] Updating system packages"
apt-get update -y && apt-get upgrade -y

echo "[+] Installing dependencies"
DEBIAN_FRONTEND=noninteractive apt-get install -y \
  apache2 \
  php \
  mysql-client \
  ruby-full \
  awscli \
  unzip \
  ufw

echo "[+] Installing CodeDeploy agent"
cd /tmp
wget https://aws-codedeploy-${var.region}.s3.${var.region}.amazonaws.com/latest/install -O install_codedeploy.sh
chmod +x install_codedeploy.sh
./install_codedeploy.sh auto

systemctl enable codedeploy-agent
systemctl start codedeploy-agent

echo "[+] Installing CloudWatch Agent"
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i -E ./amazon-cloudwatch-agent.deb

echo "[+] Configuring CloudWatch Agent from SSM"
mkdir -p /opt/aws/amazon-cloudwatch-agent/etc/
cloudwatch_config=$(aws ssm get-parameter --name AmazonCloudWatch-linux --with-decryption --region ${var.region} --query "Parameter.Value" --output text)
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/custom.json \
  -s

echo "[+] Configuring Apache"
systemctl enable apache2
systemctl start apache2
echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php

# Replace domain name with actual env variable or default
DOMAIN_NAME="${var.ec2_web_domain_name:-example.com}"
mkdir -p "/var/www/${DOMAIN_NAME}"
chown -R www-data:www-data "/var/www/${DOMAIN_NAME}"

echo "[+] Configuring firewall"
ufw allow 'Apache Full'
ufw --force enable

echo "[+] Bootstrap script finished at $(date)"
