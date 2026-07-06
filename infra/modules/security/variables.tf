variable "name_prefix" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "app_port" {
  description = "Port the application container listens on"
  type        = number
  default     = 8000
}

variable "create_db_sg" {
  description = "Whether to create the database security group (only true in the primary region, which hosts the single RDS instance)"
  type        = bool
  default     = false
}

variable "db_allowed_cidrs" {
  description = "CIDR blocks allowed to reach the database on the Postgres port — the app-tier subnets of both the primary and secondary region"
  type        = list(string)
  default     = []
}

variable "db_port" {
  type    = number
  default = 5432
}
