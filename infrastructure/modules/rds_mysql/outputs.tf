output "hostname" {
  description = "RDS instance hostname"
  value       = aws_db_instance.rds_mysql.address
  sensitive   = true
}

output "port" {
  description = "RDS instance port"
  value       = aws_db_instance.rds_mysql.port
  sensitive   = true
}

output "username" {
  description = "RDS instance root username"
  value       = aws_db_instance.rds_mysql.username
  sensitive   = true
}

output "endpoint" {
  value = aws_db_instance.rds_mysql.endpoint
}

output "identifier" {
  value = aws_db_instance.rds_mysql.identifier
}

//*/
