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

variable "app_port" {
  type    = number
  default = 8000
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
  description = "Kept at 1 by default to stay inside the Free Tier's shared 750 EC2 hours/month across both regions — raise for a real scaling demo."
  type        = number
  default     = 1
}

variable "container_image" {
  description = "ECR image URI the app instances pull and run, e.g. <account>.dkr.ecr.<region>.amazonaws.com/notes-api:latest"
  type        = string
}

variable "db_secret_arn" {
  description = "Secrets Manager ARN holding the DATABASE_URL connection string for this region"
  type        = string
}

variable "certificate_arn" {
  description = "Regional ACM certificate ARN for the ALB's HTTPS listener. Leave empty to expose HTTP only (e.g. while there's no domain yet)."
  type        = string
  default     = ""
}
