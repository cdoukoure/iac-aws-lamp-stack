/* resource "aws_db_subnet_group" "main" {
  name       = "${var.env_prefix}-subnet-group"
  subnet_ids = var.private_subnets
}

resource "aws_db_instance" "main" {
  identifier             = "${var.env_prefix}-db"
  engine                 = "mysql"
  engine_version         = "11.0.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_encrypted      = true
  username               = var.db_master_username
  password               = var.db_master_password
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = var.security_group_ids
  skip_final_snapshot    = true
  multi_az               = true
}
 */