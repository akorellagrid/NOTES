resource "aws_sns_topic" "alerts" {
  name_prefix = "${var.name_prefix}-alerts-"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

# --- Auto-stop: when actual spend crosses var.stop_trigger_usd, scale
# both ASGs to 0. AWS Budgets' built-in RUN_SSM_DOCUMENTS action only
# offers STOP_EC2_INSTANCES/STOP_RDS_INSTANCES, and stopping an
# ASG-managed instance directly is counterproductive — the ASG's ELB
# health check just sees it disappear and launches a replacement. Going
# through the ASG API (min/desired = 0) is the only way that actually
# sticks. ---

data "aws_caller_identity" "current" {}

data "archive_file" "stop_asgs" {
  type        = "zip"
  source_file = "${path.module}/lambda/stop_asgs.py"
  output_path = "${path.module}/lambda/stop_asgs.zip"
}

resource "aws_iam_role" "stop_asgs_lambda" {
  name_prefix = "${var.name_prefix}-stop-asgs-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "stop_asgs_lambda_logs" {
  role       = aws_iam_role.stop_asgs_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "stop_asgs_lambda" {
  name_prefix = "${var.name_prefix}-stop-asgs-"
  role        = aws_iam_role.stop_asgs_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "autoscaling:UpdateAutoScalingGroup"
        Resource = [
          "arn:aws:autoscaling:${var.aws_region}:${data.aws_caller_identity.current.account_id}:autoScalingGroup:*:autoScalingGroupName/${var.backend_asg_name}",
          "arn:aws:autoscaling:${var.aws_region}:${data.aws_caller_identity.current.account_id}:autoScalingGroup:*:autoScalingGroupName/${var.frontend_asg_name}",
        ]
      },
      {
        # AWS doesn't support resource-level scoping on Describe* autoscaling APIs.
        Effect   = "Allow"
        Action   = "autoscaling:DescribeAutoScalingGroups"
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = "sns:Publish"
        Resource = aws_sns_topic.alerts.arn
      }
    ]
  })
}

resource "aws_lambda_function" "stop_asgs" {
  function_name    = "${var.name_prefix}-stop-asgs"
  role             = aws_iam_role.stop_asgs_lambda.arn
  handler          = "stop_asgs.handler"
  runtime          = "python3.12"
  timeout          = 30
  filename         = data.archive_file.stop_asgs.output_path
  source_code_hash = data.archive_file.stop_asgs.output_base64sha256

  environment {
    variables = {
      ASG_NAMES       = "${var.backend_asg_name},${var.frontend_asg_name}"
      ALERT_TOPIC_ARN = aws_sns_topic.alerts.arn
    }
  }
}

resource "aws_sns_topic" "stop_trigger" {
  name_prefix = "${var.name_prefix}-stop-trigger-"
}

resource "aws_sns_topic_subscription" "stop_asgs_lambda" {
  topic_arn = aws_sns_topic.stop_trigger.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.stop_asgs.arn
}

resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowSNSInvokeStopAsgs"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stop_asgs.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.stop_trigger.arn
}

resource "aws_budgets_budget" "stop_trigger" {
  name         = "${var.name_prefix}-stop-trigger"
  budget_type  = "COST"
  limit_amount = tostring(var.stop_trigger_usd)
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator       = "GREATER_THAN"
    threshold                 = 100
    threshold_type            = "PERCENTAGE"
    notification_type         = "ACTUAL"
    subscriber_sns_topic_arns = [aws_sns_topic.stop_trigger.arn]
  }
}

# --- Alarms ---

resource "aws_cloudwatch_metric_alarm" "backend_unhealthy_hosts" {
  alarm_name          = "${var.name_prefix}-backend-unhealthy-hosts"
  alarm_description   = "Backend ALB has at least one unhealthy target"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "UnHealthyHostCount"
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 2
  comparison_operator = "GreaterThanThreshold"
  threshold           = 0
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = var.backend_alb_arn_suffix
    TargetGroup  = var.backend_tg_arn_suffix
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "frontend_unhealthy_hosts" {
  alarm_name          = "${var.name_prefix}-frontend-unhealthy-hosts"
  alarm_description   = "Frontend ALB has at least one unhealthy target"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "UnHealthyHostCount"
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 2
  comparison_operator = "GreaterThanThreshold"
  threshold           = 0
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = var.frontend_alb_arn_suffix
    TargetGroup  = var.frontend_tg_arn_suffix
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {
  alarm_name          = "${var.name_prefix}-rds-cpu-high"
  alarm_description   = "RDS CPU above 80% for 15 minutes"
  namespace           = "AWS/RDS"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 3
  comparison_operator = "GreaterThanThreshold"
  threshold           = 80

  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "rds_storage_low" {
  alarm_name          = "${var.name_prefix}-rds-storage-low"
  alarm_description   = "RDS free storage below 2GB"
  namespace           = "AWS/RDS"
  metric_name         = "FreeStorageSpace"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 1
  comparison_operator = "LessThanThreshold"
  threshold           = 2000000000 # 2 GB in bytes

  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}

# The NAT instance is a hand-rolled single point of failure for both
# ASGs' internet egress (ECR pulls, SSM, package installs) — a NAT
# Gateway wouldn't need this, but that's the Free Tier trade-off this
# design makes (see docs/aws-architecture.md §6).
resource "aws_cloudwatch_metric_alarm" "nat_status_check_failed" {
  alarm_name          = "${var.name_prefix}-nat-status-check-failed"
  alarm_description   = "NAT instance failed EC2 status checks"
  namespace           = "AWS/EC2"
  metric_name         = "StatusCheckFailed"
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 2
  comparison_operator = "GreaterThanThreshold"
  threshold           = 0

  dimensions = {
    InstanceId = var.nat_instance_id
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}

# --- Dashboard ---

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.name_prefix}-overview"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "text"
        x      = 0
        y      = 0
        width  = 24
        height = 1
        properties = {
          markdown = "# ${var.name_prefix} — Part 4 capstone overview (${var.aws_region})"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 1
        width  = 12
        height = 6
        properties = {
          title  = "Backend ALB — requests & errors"
          region = var.aws_region
          view   = "timeSeries"
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.backend_alb_arn_suffix, { stat = "Sum" }],
            ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", var.backend_alb_arn_suffix, { stat = "Sum" }],
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", var.backend_alb_arn_suffix, { stat = "Average", yAxis = "right" }],
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 1
        width  = 12
        height = 6
        properties = {
          title  = "Backend ASG & target health"
          region = var.aws_region
          view   = "timeSeries"
          metrics = [
            ["AWS/ApplicationELB", "HealthyHostCount", "TargetGroup", var.backend_tg_arn_suffix, "LoadBalancer", var.backend_alb_arn_suffix, { stat = "Minimum" }],
            ["AWS/ApplicationELB", "UnHealthyHostCount", "TargetGroup", var.backend_tg_arn_suffix, "LoadBalancer", var.backend_alb_arn_suffix, { stat = "Maximum" }],
            ["AWS/AutoScaling", "GroupInServiceInstances", "AutoScalingGroupName", var.backend_asg_name, { stat = "Average", yAxis = "right" }],
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 7
        width  = 12
        height = 6
        properties = {
          title  = "Frontend ALB — requests & errors"
          region = var.aws_region
          view   = "timeSeries"
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.frontend_alb_arn_suffix, { stat = "Sum" }],
            ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", var.frontend_alb_arn_suffix, { stat = "Sum" }],
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", var.frontend_alb_arn_suffix, { stat = "Average", yAxis = "right" }],
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 7
        width  = 12
        height = 6
        properties = {
          title  = "Frontend ASG & target health"
          region = var.aws_region
          view   = "timeSeries"
          metrics = [
            ["AWS/ApplicationELB", "HealthyHostCount", "TargetGroup", var.frontend_tg_arn_suffix, "LoadBalancer", var.frontend_alb_arn_suffix, { stat = "Minimum" }],
            ["AWS/ApplicationELB", "UnHealthyHostCount", "TargetGroup", var.frontend_tg_arn_suffix, "LoadBalancer", var.frontend_alb_arn_suffix, { stat = "Maximum" }],
            ["AWS/AutoScaling", "GroupInServiceInstances", "AutoScalingGroupName", var.frontend_asg_name, { stat = "Average", yAxis = "right" }],
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 13
        width  = 12
        height = 6
        properties = {
          title  = "RDS — CPU, storage, connections"
          region = var.aws_region
          view   = "timeSeries"
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", var.db_instance_id, { stat = "Average" }],
            ["AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", var.db_instance_id, { stat = "Average", yAxis = "right" }],
            ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", var.db_instance_id, { stat = "Average" }],
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 13
        width  = 12
        height = 6
        properties = {
          title  = "NAT instance — the single point of failure to watch"
          region = var.aws_region
          view   = "timeSeries"
          metrics = [
            ["AWS/EC2", "CPUUtilization", "InstanceId", var.nat_instance_id, { stat = "Average" }],
            ["AWS/EC2", "StatusCheckFailed", "InstanceId", var.nat_instance_id, { stat = "Maximum", yAxis = "right" }],
            ["AWS/EC2", "NetworkOut", "InstanceId", var.nat_instance_id, { stat = "Sum" }],
          ]
        }
      },
    ]
  })
}

# --- Budget ---

resource "aws_budgets_budget" "monthly" {
  name         = "${var.name_prefix}-monthly-budget"
  budget_type  = "COST"
  limit_amount = tostring(var.budget_limit_usd)
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [var.notification_email]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.notification_email]
  }
}
