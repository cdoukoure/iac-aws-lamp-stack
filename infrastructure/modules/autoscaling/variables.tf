variable "prefix" {
  description = "This is the environment your webapp will be prefixed with. dev, qa, or prod"
  type        = string
}

variable "ec2_web_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "ec2_web_min_instance" {
  type = number
  default = 2
}

variable "ec2_web_max_instance" {
  type = number
  default = 4
}

variable "web_security_group_id" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "vpc_zone_identifier" {
  type = set(string)
}

variable "aws_lb_target_group_ec2_web_arn" {
  type = string
}
