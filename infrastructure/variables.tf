# General
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "prefix" {
  description = "This is the environment your webapp will be prefixed with. dev, qa, or prod"
  type        = string
  default     = "learnterraform"
}

# Compute module
variable "ec2_autoscaling_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "ec2_autoscaling_web_domain_name" {
  description = "Nom de domaine"
  type = string
  default = "example.com"
}

variable "ec2_autoscaling_key_name" {
  description = "Nom de votre paire de clés AWS"
  type = string
  sensitive = true
}

variable "ec2_autoscaling_min_instance" {
  type    = number
  default = 2
}

variable "ec2_autoscaling_max_instance" {
  type    = number
  default = 4
}

# RDS for MySQL
variable "rds_mysql_db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "rds_mysql_db_master_username" {
  type = string
  sensitive = true
}

variable "rds_mysql_db_master_password" {
  type = string
  sensitive = true
}

# DevOps
variable "devops_github_repo_owner" {
  type = string
  sensitive = true
}

variable "devops_github_repo_name" {
  type = string
  sensitive = true
}

variable "devops_github_token" {
  type = string
  sensitive = true
}


# CloudWatch (Monitoring)
variable "cloudwatch_email_for_alert" {
  type = string
  sensitive = true
}

variable "cloudwatch_db_instance_enable_replica" {
  type = bool
  default = false
}


