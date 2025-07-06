# Rôle IAM pour RDS

resource "aws_iam_role" "rds_monitoring_role" {
  name = "${var.prefix}-RDS-Monitoring-Role"  # Ajout du prefix

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "monitoring.rds.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

## Remplacer la politique par la politique managée
resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# Groupe de sous-réseaux pour RDS
resource "aws_db_subnet_group" "rds_mysql" {
  name = "${var.prefix}-subnet-group"
  # subnet_ids = var.db_subnet_ids
  subnet_ids = var.vpc_subnet_ids

  tags = {
    Name = "RDS MySQL"
  }
}

/* resource "aws_db_instance" "rds_mysql" {
  identifier             = "${var.prefix}-db"
  db_subnet_group_name   = aws_db_subnet_group.rds_mysql.name
  engine                 = var.db_engine
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  username               = var.db_master_username
  password               = var.db_master_password
  vpc_security_group_ids = var.vpc_security_group_ids # [aws_security_group.rds_mysql.id]
  skip_final_snapshot    = true
  multi_az               = true
  allocated_storage      = 20
  max_allocated_storage  = var.db_max_allocated_storage
} */

# Instance RDS MySQL
resource "aws_db_instance" "mysql" {
  identifier             = "${var.prefix}-db"
  db_subnet_group_name   = aws_db_subnet_group.rds_mysql.name
  vpc_security_group_ids = var.vpc_security_group_ids # [aws_security_group.rds_mysql.id]
  engine                 = var.db_engine
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  username               = var.db_master_username
  password               = var.db_master_password
  db_name                = var.db_name
  allocated_storage      = 20
  max_allocated_storage  = var.db_max_allocated_storage
  storage_type           = "gp2"
  multi_az               = var.db_multi_az
  publicly_accessible    = false
  skip_final_snapshot    = true
  backup_retention_period = var.db_backup_retention_period
  backup_window          = "03:00-04:00"  # Fenêtre de sauvegarde quotidienne
  maintenance_window     = "sun:04:00-sun:05:00"

  # Paramètres de performance
  parameter_group_name = aws_db_parameter_group.mysql.name

  # Options avancées
  deletion_protection = true
  apply_immediately   = true

  tags = {
    Name = "MySQL Database"
  }
}

# Groupe de paramètres personnalisés
resource "aws_db_parameter_group" "mysql" {
  name        = "mysql-parameter-group"
  family      = "mysql8.0"
  description = "Paramètres personnalisés pour MySQL"

  parameter {
    name  = "max_connections"
    value = "1000"
  }

  parameter {
    name  = "innodb_buffer_pool_size"
    value = "{DBInstanceClassMemory*3/4}"
  }
}

  

