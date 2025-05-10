/* resource "aws_launch_template" "lamp" {
  name_prefix   = "${var.env_prefix}-lt"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name      = "lamp-key"
  user_data     = base64encode(file("${path.module}/user_data.sh"))

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.ec2.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.env_prefix}-instance"
    }
  }
}

resource "aws_autoscaling_group" "main" {
  name                = "${var.env_prefix}-asg"
  min_size            = 2
  max_size            = 4
  desired_capacity    = 2
  vpc_zone_identifier = var.public_subnets

  launch_template {
    id      = aws_launch_template.lamp.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.main.arn]

  tag {
    key                 = "Environment"
    value               = var.env_prefix
    propagate_at_launch = true
  }
}

resource "aws_lb_target_group" "main" {
  name     = "${var.env_prefix}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
} */