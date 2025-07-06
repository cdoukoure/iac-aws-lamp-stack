
output "group_name" {
  value = aws_autoscaling_group.ec2_web.name
}

output "image_id" {
  value = data.aws_ami.ubuntu.id
}

output "role_id" {
  value = aws_iam_role.ec2_web.id
}