variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "lamp" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "ExampleAppServerInstance"
}


variable "instance_count" {
  description = "Number of instances to provision."
  type        = number
  default     = 2
}

variable "enable_vpn_gateway" {
  description = "Enable a VPN gateway in your VPC."
  type        = bool
  default     = false
}

# Network 

variable "public_subnet_count" {
  description = "Number of public subnets."
  type        = number
  default     = 2
}

variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnet_count" {
  description = "Number of private subnets."
  type        = number
  default     = 2
}

variable "public_subnet_cidr_blocks" {
  description = "Available cidr blocks for public subnets."
  type        = list(string)
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
    "10.0.4.0/24",
    "10.0.5.0/24",
    "10.0.6.0/24",
    "10.0.7.0/24",
    "10.0.8.0/24",
  ]
}

variable "private_subnet_cidr_blocks" {
  description = "Available cidr blocks for private subnets."
  type        = list(string)
  default = [
    "10.0.101.0/24",
    "10.0.102.0/24",
    "10.0.103.0/24",
    "10.0.104.0/24",
    "10.0.105.0/24",
    "10.0.106.0/24",
    "10.0.107.0/24",
    "10.0.108.0/24",
  ]
}

