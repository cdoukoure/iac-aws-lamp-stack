variable "prefix" {
  description = "This is the environment your webapp will be prefixed with. dev, qa, or prod"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "email_for_alert" {
  type = string
}

variable "db_instance_identifier" {
  type = string
}

variable "db_instance_enable_replica" {
  type = string
}

variable "autoscaling_group_name" {
  type = string
}

variable "autoscaling_group_instance_type" {
  type = string
}

variable "autoscaling_group_image_id" {
  type = string
}

variable "autoscaling_group_ec2_role_id" {
  type = string
}