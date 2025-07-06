# Il faut avoir un fichier appspec.yml à la base du dépôt Github de votre projet
version: 0.0
os: linux
files:
  - source: /                   # Tous les fichiers du dépôt
    destination: /var/www/html  # Destination sur les instances EC2
    # destination: /var/www/html/wordpress/wp-content/themes/ # Destination sur les instances EC2
    # destination: /var/www/html/wordpress/wp-content/plugins/ # Destination sur les instances EC2
hooks:
  AfterInstall: # Actions à mener sur le serveur après le push des fichiers
    - location: scripts/restart_server.sh 
      timeout: 300
      runas: root


## Exemple de projet
/Depot Github
├── appspec.yml
├── index.php
├── styles.css
└── scripts/
    └── restart_server.sh

## Exemple scripts/restart_server.sh
<!-- 
#!/bin/bash
systemctl restart httpd 
-->
