/*
data "aws_ami" "ubuntu" {
  most_recent = true
  # owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}
//*/

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_launch_template" "ec2_web" {
  name_prefix   = "${var.prefix}-lt"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.ec2_web_instance_type
  user_data     = filebase64("${path.module}/user-data.sh")
  # user_data     = base64encode(file("${path.module}/user-data.sh"))
  # key_name      = "ec2_web-key"

  network_interfaces {
    # associate_public_ip_address = true
    security_groups = [var.web_security_group_id] # [aws_security_group.ec2_web.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.prefix}-ec2_web-instance"
    }
  }
}

resource "aws_autoscaling_group" "ec2_web" {
  name                = "${var.prefix}-asg"
  min_size            = var.ec2_web_min_instance
  max_size            = var.ec2_web_max_instance
  desired_capacity    = var.ec2_web_min_instance
  vpc_zone_identifier = var.vpc_zone_identifier
  # vpc_zone_identifier = module.vpc.public_subnets NOK
  # vpc_zone_identifier = module.vpc.private_subnets OK

  launch_template {
    id      = aws_launch_template.ec2_web.id
    version = "$Latest"
  }

  target_group_arns = [var.aws_lb_target_group_ec2_web_arn] # [aws_lb_target_group.ec2_web.arn]

  tag {
    key                 = "Environment"
    value               = var.prefix
    propagate_at_launch = true
  }
}

//*/

/*
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_launch_configuration" "ec2_web" {
  name_prefix   = "${var.prefix}-lt"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  # user_data     = file("user-data.sh")
  user_data     = base64encode(file("${path.module}/user_data.sh"))
  security_groups = [var.web_security_group_id] # [aws_security_group.ec2_web.id]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "ec2_web" {
  name                 = "${var.prefix}-asg"
  min_size             = 1
  max_size             = 3
  desired_capacity     = 1
  launch_configuration = aws_launch_configuration.ec2_web.name
  # vpc_zone_identifier  = module.vpc.public_subnets
  vpc_zone_identifier = var.vpc_zone_identifier

  health_check_type = "ELB"

  tag {
    key                 = "Name"
    value               = "HashiCorp ASG"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_attachment" "ec2_web" {
  autoscaling_group_name = aws_autoscaling_group.ec2_web.id
  lb_target_group_arn    = var.aws_lb_target_group_ec2_web_arn # Create a new ALB Target Group attachment
  # elb                    = aws_elb.example.id              # Create a new load balancer attachment
}

//*/


