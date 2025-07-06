#!/bin/bash

# Mise à jour du système
apt-get update -y
apt-get upgrade -y

# Installation des dépendances
DEBIAN_FRONTEND=noninteractive apt-get install -y \
    apache2 \
    php \
    libapache2-mod-php \
    php-mysql \
    php-curl \
    php-gd \
    php-intl \
    php-mbstring \
    php-soap \
    php-xml \
    php-xmlrpc \
    php-zip \
    php-fpm \
    php-common \
    mariadb-client \
    mysql-client \
    ruby-full \
    awscli \
    unzip


cd /tmp


# Installation de CodeDeploy Agent
wget https://aws-codedeploy-${var.region}.s3.${var.region}.amazonaws.com/latest/install
chmod +x ./install
./install auto > /tmp/codedeploy_install.log
sudo service codedeploy-agent start

# Installation de CloudWatch Agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i -E ./amazon-cloudwatch-agent.deb

# Configuration de CloudWatch Agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -c ssm:AmazonCloudWatch-linux \
    -s

# Démarrer et activer Apache
systemctl start apache2
systemctl enable apache2
echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php

sudo ufw allow 'Apache Full'

# Télécharger WordPress 
wget https://wordpress.org/wordpress-${var.wp_version}.tar.gz -O wordpress.tar.gz

# Télécharger la somme de contrôle
wget https://wordpress.org/wordpress-${var.wp_version}.tar.gz.sha256

# Vérifier l'intégrité
sha256sum -c wordpress-${var.wp_version}.tar.gz.sha256

# Décompresser
tar -xvzf /tmp/wordpress.tar.gz -C /var/www/html/

chown -R www-data:www-data /var/www/html/wordpress
chmod -R 755 /var/www/html/wordpress

# Configurer WordPress
cp /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php

# Tester la connexion à la base RDS
echo "Vérification de la connexion à la base RDS..."
if ! mysql -h "${var.rds_endpoint}" -P "${var.rds_port}" -u "${var.rds_username}" -p "${var.rds_password}" -e "SHOW DATABASES;" ; then
    echo "Échec de la connexion à la base de données. Vérifiez vos informations."
    exit 1
fi

# Créer la base de données si elle n'existe pas
mysql -h "${var.rds_endpoint}" -P "${var.rds_port}" -u "${var.rds_username}" -p "${var.rds_password}" <<MYSQL_SCRIPT
CREATE DATABASE IF NOT EXISTS ${var.rds_database} DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
MYSQL_SCRIPT

# Configurer wp-config.php
sed -i "s/define( 'DB_NAME', 'database_name_here' );/define( 'DB_NAME', '${var.rds_database}' );/" /var/www/html/wordpress/wp-config.php
sed -i "s/define( 'DB_USER', 'username_here' );/define( 'DB_USER', '${var.rds_username}' );/" /var/www/html/wordpress/wp-config.php
sed -i "s/define( 'DB_PASSWORD', 'password_here' );/define( 'DB_PASSWORD', '${var.rds_password}' );/" /var/www/html/wordpress/wp-config.php
sed -i "s/define( 'DB_HOST', 'localhost' );/define( 'DB_HOST', '${var.rds_endpoint}:${var.rds_port}' );/" /var/www/html/wordpress/wp-config.php

# Ajouter les clés de sécurité WordPress
perl -i -pe'
  BEGIN {
    @chars = ("a" .. "z", "A" .. "Z", 0 .. 9);
    push @chars, split //, "!@#$%^&*()-_ []{}<>~\`+=,.;:/?|";
    sub salt { join "", map $chars[ rand @chars ], 1 .. 64 }
  }
  s/put your unique phrase here/salt()/ge
' /var/www/html/wordpress/wp-config.php

# Configurer les permaliens
cat > /var/www/html/wordpress/.htaccess <<EOF
# BEGIN WordPress
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
</IfModule>
# END WordPress
EOF

# Configurer Apache
cat > /etc/apache2/sites-available/wordpress.conf <<EOF
<VirtualHost *:80>
    ServerAdmin admin@${var.ec2_web_domain_name}
    DocumentRoot /var/www/html/wordpress
    ServerName ${var.ec2_web_domain_name}
    ServerAlias www.${var.ec2_web_domain_name}

    <Directory /var/www/html/wordpress>
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

# Activer la configuration
a2ensite wordpress
a2dissite 000-default
a2enmod rewrite
systemctl restart apache2

# Configurer les permissions
chown -R www-data:www-data /var/www/html/wordpress
find /var/www/html/wordpress/ -type d -exec chmod 750 {} \;
find /var/www/html/wordpress/ -type f -exec chmod 640 {} \;

# Nettoyage
rm -f /tmp/*.deb /tmp/install