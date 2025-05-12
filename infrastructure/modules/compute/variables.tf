variable "prefix" {
  description = "This is the environment your webapp will be prefixed with. dev, qa, or prod"
  type        = string
}

variable "web_security_group_id" {
  type    = string
}

variable "vpc_id" {
  type    = string
}

variable "vpc_zone_identifier" {
  type = set(string)
}

variable "aws_lb_target_group_ec2_web_arn" {
  type = string
}