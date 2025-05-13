#!/bin/bash
    
sudo apt-get update

# Installation de l'agent CodeDeploy
sudo apt-get install -y ruby-full wget
cd /home/ubuntu
wget https://aws-codedeploy-${var.region}.s3.${var.region}.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto
sudo service codedeploy-agent start

# Installation de LAMP
apt-get install -y apache2 php mysql-client
systemctl start apache2

sudo ufw allow 'Apache Full'

# sudo mkdir -p /var/www/example.com
# sudo chown -R www-data: /var/www/example.com