variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "azs" {
  type    = list(string)
  default = ["ap-south-1a", "ap-south-1b"]
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "db_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.20.0/24", "10.0.21.0/24"]
}

variable "secondary_vpc_cidr" {
  description = "Secondary region's VPC CIDR — needed here so the DB security group can allow inbound from it"
  type        = string
  default     = "10.1.0.0/16"
}

variable "secondary_region" {
  type    = string
  default = "ap-southeast-1"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "desired_capacity" {
  type    = number
  default = 1
}

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 4
}

variable "container_image_tag" {
  type    = string
  default = "latest"
}

variable "certificate_arn" {
  type    = string
  default = ""
}

variable "notification_email" {
  description = "Where CloudWatch alarm and Budget notifications go. Requires confirming an SNS subscription email after apply."
  type        = string
  default     = "aadityakumar4042@gmail.com"
}

variable "budget_limit_usd" {
  type    = number
  default = 10
}

variable "stop_trigger_usd" {
  description = "Actual monthly spend at which both ASGs auto-scale to 0. See infra/modules/monitoring for the lag caveat."
  type        = number
  default     = 2
}
