variable "prefix" {
  description = "This is the environment your webapp will be prefixed with. dev, qa, or prod"
  type        = string
}

variable "db_max_allocated_storage" {
  type    = number
  default = 100
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "db_engine" {
  type    = string
  default = "mysql"
}

variable "db_engine_version" {
  type    = string
  default = "8.4.5"
}

variable "db_name" {
  description = "Nom de la base de données"
  type        = string
  default     = "mydatabase"
}

variable "db_master_username" {
  sensitive = true
}

variable "db_master_password" {
  sensitive = true
}

variable "db_backup_retention_period" {
  description = "Durée de rétention des sauvegardes (jours)"
  type        = number
  default     = 7
}

variable "db_multi_az" {
  description = "Activer le déploiement Multi-AZ"
  type        = bool
  default     = true
}

variable "vpc_subnet_ids" {
  type = set(string)
  # type = string
}

variable "vpc_security_group_ids" {
  type = set(string)
}
