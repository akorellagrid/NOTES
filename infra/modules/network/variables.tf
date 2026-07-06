variable "name_prefix" {
  description = "Prefix used on all resource names/tags created by this module"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for this region's VPC"
  type        = string
}

variable "azs" {
  description = "Availability zones to spread subnets across (exactly 2)"
  type        = list(string)

  validation {
    condition     = length(var.azs) == 2
    error_message = "Provide exactly 2 availability zones."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDRs for the two public subnets (ALB + NAT instance)"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDRs for the two private subnets (app instances, no public IP)"
  type        = list(string)
}

variable "db_subnet_cidrs" {
  description = "CIDRs for the two DB subnets. Leave empty in regions with no local database (RDS requires a subnet group spanning 2 AZs even for a single instance)."
  type        = list(string)
  default     = []
}

variable "nat_instance_type" {
  description = "Instance type for the NAT instance. Free-tier substitute for NAT Gateway, which is never free-tier eligible."
  type        = string
  default     = "t3.micro"
}
