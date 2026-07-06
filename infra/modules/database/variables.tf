variable "name_prefix" {
  type = string
}

variable "db_subnet_ids" {
  description = "Subnet IDs for the DB subnet group (must span 2 AZs; only one instance actually runs)"
  type        = list(string)
}

variable "db_sg_id" {
  type = string
}

variable "instance_class" {
  description = "Free Tier eligible: db.t3.micro / db.t2.micro (750 instance-hours/month for 12 months)"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  type    = number
  default = 20
}

variable "engine_version" {
  type    = string
  default = "16"
}

variable "db_name" {
  type    = string
  default = "notes_db"
}

variable "db_username" {
  type    = string
  default = "notes_user"
}

variable "backup_retention_period" {
  description = "Days of automated backups to retain. Accounts still under the Free Tier restriction cap this low (1 day observed) regardless of the general RDS max of 35."
  type        = number
  default     = 1
}

variable "replica_region" {
  description = "Region to replicate the DB-credentials secret into, so the secondary region's app tier can resolve DATABASE_URL without hardcoding it. Leave empty to skip replication."
  type        = string
  default     = ""
}
