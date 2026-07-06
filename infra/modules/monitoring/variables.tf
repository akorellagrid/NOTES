variable "name_prefix" {
  type = string
}

variable "notification_email" {
  description = "Where alarm and budget notifications go. The SNS subscription requires clicking a confirmation link sent to this address before alarms actually deliver."
  type        = string
}

variable "budget_limit_usd" {
  description = "Monthly cost budget in USD. Notifies at 80% (forecasted) and 100% (actual)."
  type        = number
  default     = 10
}

variable "backend_alb_arn_suffix" {
  type = string
}

variable "backend_tg_arn_suffix" {
  type = string
}

variable "backend_asg_name" {
  type = string
}

variable "frontend_alb_arn_suffix" {
  type = string
}

variable "frontend_tg_arn_suffix" {
  type = string
}

variable "frontend_asg_name" {
  type = string
}

variable "db_instance_id" {
  type = string
}

variable "nat_instance_id" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "stop_trigger_usd" {
  description = "Actual monthly spend (USD) at which both ASGs get scaled to 0 automatically. AWS cost data lags by hours, so this is a safety net, not a real-time cutoff."
  type        = number
  default     = 2
}
