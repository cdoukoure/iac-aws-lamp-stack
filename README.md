# 🚀 Projet DevOps : Infrastructure LAMP Auto Scaling sur AWS avec CI/CD et Monitoring

Ce projet démontre la mise en place d'une infrastructure cloud complète, scalable et sécurisée sur AWS, avec automatisation du déploiement d'une application web LAMP (Linux, Apache, MySQL, PHP) via Terraform et script de bootstrap, CI/CD via CodePipeline, et monitoring avec CloudWatch.

---

## 📦 Stack Technique

| Domaine         | Outils/Services                        |
| --------------- | -------------------------------------- |
| Infrastructure  | Terraform                              |
| Cloud Provider  | AWS (EC2, VPC, RDS, ASG, CodePipeline) |
| Config Serveur  | Script Bash (user\_data), Apache, PHP  |
| CI/CD           | AWS CodePipeline + CodeDeploy          |
| Monitoring      | AWS CloudWatch + CloudWatch Agent      |
| Base de Données | Amazon RDS (MySQL)                     |
| OS              | Ubuntu Server 20.04                    |

---

## 🗺 Architecture du Projet

```text
                              +-------------------+
                              |    Utilisateur    |
                              +-------------------+
                                        |
                                        v
                          +----------------------------+
                          |        Load Balancer       |
                          +----------------------------+
                                       / \
                                      /   \
                                     /     \
              +------------------+           +------------------+
              |     EC2-1        |           |     EC2-2        |   <-- Instances Auto Scaling
              | Apache + PHP     |           | Apache + PHP     |
              | CodeDeploy Agent |           | CodeDeploy Agent |
              | CloudWatch Agent |           | CloudWatch Agent |
              +------------------+           +------------------+
                      |                            |
                      +----------------------------+
                                   |
                        +-----------------------+
                        |     Amazon RDS        |
                        |     MySQL Database    |
                        +-----------------------+

CI/CD:
- GitHub (ou CodeCommit) --> CodePipeline --> CodeDeploy --> EC2

Monitoring:
- Logs et métriques collectés via CloudWatch Agent
```

---

## ⚙ Fonctionnalités

* Provisionnement **Infrastructure-as-Code** avec Terraform
* Déploiement automatisé d'une **application LAMP** avec script bash idempotent
* Configuration de **CodeDeploy** pour les mises à jour continues
* Intégration de **CloudWatch Agent** pour logs et métriques
* Architecture **scalable** avec Auto Scaling Group et Load Balancer

---

## 🚀 Déploiement

### 1. Initialisation Terraform

```bash
cd terraform
terraform init
terraform apply -var="region=us-east-1"
```

### 2. Infrastructure créée

* VPC avec sous-réseaux publics/privés
* Security Groups restreints
* EC2 Auto Scaling avec script bootstrap
* RDS MySQL configuré

### 3. Script de bootstrap

Script bash exécuté à la création de chaque instance pour installer :

* Apache, PHP
* AWS CodeDeploy Agent
* AWS CloudWatch Agent
* Configuration du VirtualHost Apache

### 4. Pipeline CI/CD

* Code source pushé vers GitHub ou CodeCommit
* CodePipeline déclenché
* Build puis déploiement sur les instances EC2 via CodeDeploy

---

## 🔐 Sécurité

* Accès SSH limité par Security Groups
* Accès DB uniquement depuis le VPC
* Utilisation d'instances IAM avec permissions minimales
* Firewall activé (UFW)

---

## 📊 Monitoring & Logs

* CloudWatch Agent envoie logs Apache, journaux système
* Dashboard CloudWatch personnalisé
* Alarmes CloudWatch pour charge CPU et erreurs Apache

---

## 📁 Structure du Dépôt

```
.
├── ansible/                    # Config avec Packer
├── infrastructure/             # Code Terraform (VPC, EC2, RDS, etc.)
    ├── modules
        ├── CI/CD/
        ├── Cloudwatch/
        ├── EC2 autoscaling/
            ├── user_data.sh  # Script bash user_data
        ├── RDS MySQL/
        ├── VPC/
├── diagrams/                   # Schémas d'architecture
├── .github/workflows/          # Actions pour tests Terraform
├── README.md                   # Ce fichier
```

---

## 🎯 Objectifs Pédagogiques

Ce projet montre ma capacité à :

* Concevoir une architecture cloud scalable
* Automatiser le provisionnement avec Terraform
* Utiliser des scripts de configuration auto-exécutés (bootstrap)
* Déployer en continu via AWS CodePipeline
* Superviser l’infrastructure avec CloudWatch

---

## 👤 Auteur

Jean Charles Doukouré
Ingénieur informatique - Spécialisation DevOps & Cloud
[LinkedIn](https://www.linkedin.com/in/...) • [GitHub](https://github.com/cdoukoure)

---

## 🔗 Liens utiles

* [Terraform Docs](https://developer.hashicorp.com/terraform/docs)
* [AWS CodeDeploy](https://docs.aws.amazon.com/codedeploy/)
* [CloudWatch Agent Setup](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Install-CloudWatch-Agent.html)
