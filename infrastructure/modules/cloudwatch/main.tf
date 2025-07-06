/*

# 1. Métriques et alertes pour EC2 Auto Scaling
resource "aws_cloudwatch_metric_alarm" "ec2_cpu_high" {
  alarm_name          = "ec2-high-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "CPU utilization exceeds 80%"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  dimensions = {
    AutoScalingGroupName = var.autoscaling_group_name
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_status_check_failed" {
  alarm_name          = "ec2-status-check-failed"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "1"
  alarm_description   = "EC2 instance status check failed"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  dimensions = {
    AutoScalingGroupName = var.email_for_alert
  }
}

# 2. Métriques et alertes pour RDS MySQL
resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {
  alarm_name          = "rds-high-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "85"
  alarm_description   = "RDS CPU utilization exceeds 85%"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  dimensions = {
    DBInstanceIdentifier = var.db_instance_identifier # aws_db_instance.mysql.identifier
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_storage_low" {
  alarm_name          = "rds-low-storage"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "600"
  statistic           = "Average"
  threshold           = "10737418240" # 10 GB
  alarm_description   = "RDS free storage less than 10GB"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  dimensions = {
    DBInstanceIdentifier = var.db_instance_identifier # aws_db_instance.mysql.identifier
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_connections_high" {
  alarm_name          = "rds-high-connections"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "100"
  alarm_description   = "RDS database connections exceed 100"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  dimensions = {
    DBInstanceIdentifier = var.db_instance_identifier # aws_db_instance.mysql.identifier
  }
}

# 3. Dashboard CloudWatch
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.prefix}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", var.autoscaling_group_name],
            [".", "NetworkIn", ".", "."],
            [".", "NetworkOut", ".", "."]
          ]
          period = 300
          stat   = "Average"
          region = var.region
          title  = "EC2 Metrics"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", var.db_instance_identifier],
            [".", "FreeStorageSpace", ".", "."],
            [".", "DatabaseConnections", ".", "."]
          ]
          period = 300
          stat   = "Average"
          region = var.region
          title  = "RDS Metrics"
        }
      }
    ]
  })
}

# 4. SNS pour les notifications d'alerte
resource "aws_sns_topic" "alarms" {
  name = "ec2-rds-alarms"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.alarms.arn
  protocol  = "email"
  endpoint  = var.email_for_alert # Remplacez par votre email
}

# 5. IAM Role pour CloudWatch (si nécessaire pour des actions supplémentaires)
resource "aws_iam_role" "cloudwatch_role" {
  name = "cloudwatch-action-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "events.amazonaws.com"
      }
    }]
  })
}

//*/





# 1. Métriques et alertes pour EC2 Auto Scaling
resource "aws_cloudwatch_metric_alarm" "ec2_cpu_high" {
  alarm_name          = "ec2-high-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "CPU utilization exceeds 80%"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  dimensions = {
    AutoScalingGroupName = var.autoscaling_group_name
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_status_check_failed" {
  alarm_name          = "ec2-status-check-failed"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "1"
  alarm_description   = "EC2 instance status check failed"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  dimensions = {
    AutoScalingGroupName = var.autoscaling_group_name
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_memory_high" {
  alarm_name          = "ec2-high-memory"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"  # Nécessite l'agent CloudWatch
  period              = "300"
  statistic           = "Average"
  threshold           = "85"
  alarm_description   = "EC2 memory utilization exceeds 85%"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  dimensions = {
    AutoScalingGroupName = var.autoscaling_group_name
    ImageId              = var.autoscaling_group_image_id # data.aws_ami.amazon_linux_2.id
    InstanceType         = var.autoscaling_group_instance_type
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_disk_high" {
  alarm_name          = "ec2-high-disk"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "disk_used_percent"
  namespace           = "CWAgent"  # Nécessite l'agent CloudWatch
  period              = "300"
  statistic           = "Average"
  threshold           = "90"
  alarm_description   = "EC2 disk utilization exceeds 90%"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  dimensions = {
    AutoScalingGroupName = var.autoscaling_group_name
    ImageId              = var.autoscaling_group_image_id
    InstanceType         = var.autoscaling_group_instance_type
    path                 = "/"  # Surveillance de la partition racine
    device               = "xvda1"
    fstype               = "xfs"
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_network_high" {
  alarm_name          = "ec2-high-network"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "NetworkPacketsOut"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Sum"
  threshold           = "10000"
  alarm_description   = "EC2 network out packets exceed 10,000/sec"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  dimensions = {
    AutoScalingGroupName = var.autoscaling_group_name
  }
}

# Métriques pour RDS MySQL
resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {
  alarm_name          = "rds-high-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "85"
  alarm_description   = "RDS CPU utilization exceeds 85%"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  dimensions = {
    DBInstanceIdentifier =  var.db_instance_identifier # aws_db_instance.mysql.identifier
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_storage_low" {
  alarm_name          = "rds-low-storage"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "600"
  statistic           = "Average"
  threshold           = "10737418240" # 10 GB
  alarm_description   = "RDS free storage less than 10GB"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  dimensions = {
    DBInstanceIdentifier =  var.db_instance_identifier # aws_db_instance.mysql.identifier
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_connections_high" {
  alarm_name          = "rds-high-connections"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "100"
  alarm_description   = "RDS database connections exceed 100"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  dimensions = {
    DBInstanceIdentifier =  var.db_instance_identifier # aws_db_instance.mysql.identifier
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_read_latency" {
  alarm_name          = "rds-high-read-latency"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "ReadLatency"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "0.5" # 500ms
  alarm_description   = "RDS read latency exceeds 500ms"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  dimensions = {
    DBInstanceIdentifier =  var.db_instance_identifier # aws_db_instance.mysql.identifier
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_write_latency" {
  alarm_name          = "rds-high-write-latency"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "WriteLatency"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "0.5" # 500ms
  alarm_description   = "RDS write latency exceeds 500ms"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  dimensions = {
    DBInstanceIdentifier =  var.db_instance_identifier # aws_db_instance.mysql.identifier
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_replica_lag" {
  count = var.db_instance_enable_replica ? 1 : 0

  alarm_name          = "rds-high-replica-lag"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "ReplicaLag"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "60" # 60 secondes
  alarm_description   = "RDS replica lag exceeds 60 seconds"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  dimensions = {
    DBInstanceIdentifier =  var.db_instance_identifier # aws_db_instance.mysql.identifier
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_queue_depth" {
  alarm_name          = "rds-high-queue-depth"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "DiskQueueDepth"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "64"
  alarm_description   = "RDS disk queue depth exceeds 64"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  dimensions = {
    DBInstanceIdentifier =  var.db_instance_identifier # aws_db_instance.mysql.identifier
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_deadlocks" {
  alarm_name          = "rds-high-deadlocks"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "Deadlocks"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "RDS deadlocks exceed 5 in 5 minutes"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  dimensions = {
    DBInstanceIdentifier =  var.db_instance_identifier # aws_db_instance.mysql.identifier
  }
}

# Dashboard CloudWatch
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.prefix}-ec2-rds-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", var.autoscaling_group_name],
            ["AWS/EC2", "NetworkOut", "AutoScalingGroupName", var.autoscaling_group_name],
            ["AWS/EC2", "StatusCheckFailed", "AutoScalingGroupName", var.autoscaling_group_name],
            ["CWAgent", "mem_used_percent", "AutoScalingGroupName", var.autoscaling_group_name],
            ["CWAgent", "disk_used_percent", "AutoScalingGroupName", var.autoscaling_group_name]
          ]
          period = 300
          stat   = "Average"
          region = var.region
          title  = "EC2 Metrics"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", var.db_instance_identifier],
            ["AWS/RDS", "FreeStorageSpace", ".", "."],
            ["AWS/RDS", "DatabaseConnections", ".", "."],
            ["AWS/RDS", "ReplicaLag", ".", "."],
            ["AWS/RDS", "ReadLatency", ".", "."],
            ["AWS/RDS", "WriteLatency", ".", "."],
            ["AWS/RDS", "DiskQueueDepth", ".", "."],
            ["AWS/RDS", "Deadlocks", ".", "."]
          ]
          period = 300
          stat   = "Average"
          region = var.region
          title  = "RDS Metrics"
        }
      },
      {
        type   = "alarm"
        x      = 0
        y      = 6
        width  = 24
        height = 6

        properties = {
          title = "Alarm Status"
          alarms = [
            aws_cloudwatch_metric_alarm.ec2_cpu_high.arn,
            aws_cloudwatch_metric_alarm.ec2_status_check_failed.arn,
            aws_cloudwatch_metric_alarm.ec2_memory_high.arn,
            aws_cloudwatch_metric_alarm.ec2_disk_high.arn,
            aws_cloudwatch_metric_alarm.rds_cpu_high.arn,
            aws_cloudwatch_metric_alarm.rds_storage_low.arn,
            aws_cloudwatch_metric_alarm.rds_connections_high.arn,
            aws_cloudwatch_metric_alarm.rds_read_latency.arn,
            aws_cloudwatch_metric_alarm.rds_write_latency.arn,
            var.db_instance_enable_replica ? aws_cloudwatch_metric_alarm.rds_replica_lag[0].arn : ""
          ]
        }
      }
    ]
  })
}

# SNS pour les notifications
resource "aws_sns_topic" "alarms" {
  name = "ec2-rds-alarms"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.alarms.arn
  protocol  = "email"
  endpoint  = var.email_for_alert
}

# Configuration de l'agent CloudWatch pour EC2 (nécessaire pour mémoire/disque)
resource "aws_iam_role_policy" "cloudwatch_agent_policy" {
  name = "${var.prefix}-cloudwatch-agent-policy"
  role = var.autoscaling_group_ec2_role_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData",
          "ec2:DescribeVolumes",
          "ec2:DescribeTags",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups",
          "logs:CreateLogStream",
          "logs:CreateLogGroup"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter"
        ]
        Resource = "arn:aws:ssm:*:*:parameter/AmazonCloudWatch-*"
      }
    ]
  })
}

