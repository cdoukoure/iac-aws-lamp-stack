
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_iam_role" "ec2_web" {
  name = "${var.prefix}-ec2_web-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_code_deploy" {
  role       = aws_iam_role.ec2_web.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2_web.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.ec2_web.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ec2_web" {
  name = "${var.prefix}-ec2_web-profile"
  role = aws_iam_role.ec2_web.name
}

resource "aws_launch_template" "ec2_web" {
  name_prefix   = "${var.prefix}-lt"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.ec2_web_instance_type
  user_data     = filebase64("${path.module}/user-data.sh")

  key_name = var.ec2_web_key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_web.name
  }

  network_interfaces {
    associate_public_ip_address = true
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

  lifecycle {
    ignore_changes = [desired_capacity]
  }

  target_group_arns = [var.aws_lb_target_group_ec2_web_arn] # [aws_lb_target_group.ec2_web.arn]

  tag {
    key                 = "Environment"
    value               = var.prefix
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "target_tracking" {
  name                   = "cpu-target-tracking"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.ec2_web.name

  target_tracking_configuration {
    target_value = 60.0 # Maintenir 60% d'utilisation CPU

    predefined_metric_specification {
      # Métriques prédéfinies courantes :
      # - ASGAverageCPUUtilization
      # - ASGAverageNetworkIn
      # - ASGAverageNetworkOut
      # - ALBRequestCountPerTarget (avec dimensions supplémentaires)
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    
  }
}


