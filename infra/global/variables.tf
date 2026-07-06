variable "primary_region" {
  type    = string
  default = "ap-south-1"
}

variable "secondary_region" {
  type    = string
  default = "ap-southeast-1"
}

variable "create_dns_records" {
  description = "Whether to create Route 53 latency-routing records + health checks. Requires an existing hosted zone (i.e. a domain you actually own) — leave false to test each region's ALB DNS name directly."
  type        = bool
  default     = false
}

variable "hosted_zone_id" {
  description = "Existing Route 53 hosted zone ID to add records to. Required if create_dns_records = true."
  type        = string
  default     = ""
}

variable "record_name" {
  description = "DNS name to create in the hosted zone, e.g. notes.example.com"
  type        = string
  default     = ""
}
