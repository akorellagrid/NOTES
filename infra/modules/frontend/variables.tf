variable "name_prefix" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "alb_sg_id" {
  type = string
}

variable "app_sg_id" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "health_check_path" {
  type    = string
  default = "/health"
}

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 4
}

variable "desired_capacity" {
  type    = number
  default = 1
}

variable "container_image" {
  description = "ECR image URI for the frontend (nginx + built static assets)"
  type        = string
}

variable "api_upstream" {
  description = "host:port of the backend ALB that /api/* gets reverse-proxied to, e.g. notes-....elb.amazonaws.com:80"
  type        = string
}

variable "certificate_arn" {
  type    = string
  default = ""
}
