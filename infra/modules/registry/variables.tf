variable "name_prefix" {
  type = string
}

variable "repository_name" {
  type    = string
  default = "notes-api"
}

variable "replica_region" {
  description = "Region to replicate images into, so the secondary region pulls from a local registry instead of across regions. Leave empty to skip replication."
  type        = string
  default     = ""
}
