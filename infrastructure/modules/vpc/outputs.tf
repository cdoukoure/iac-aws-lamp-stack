output "vpc_id" {
  description = "VPC id"
  value       = aws_vpc.main.id
}

output "subnet_public_ids" {
  description = "VPC Public id"
  value       = aws_subnet.public[*].id # Sous-réseaux privés du VPC
}

output "subnet_private_ids" {
  description = "VPC Private id"
  value       = aws_subnet.private[*].id # Sous-réseaux privés du VPC
}

output "alb_id" {
  value = aws_lb.main.id
}

output "alb_dns_name" {
  value = aws_lb.main.dns_name
}

output "sg_alb_id" {
  value = aws_security_group.alb.id
}

output "sg_ec2_web_id" {
  value = aws_security_group.ec2_web.id
}

output "sg_rds_mysql_id" {
  value = aws_security_group.rds_mysql.id
}

output "lb_target_group_ec2_web_arn" {
  value = aws_lb_target_group.ec2_web.arn
}





