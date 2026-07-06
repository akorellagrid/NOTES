terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  alias  = "primary"
  region = var.primary_region
}

provider "aws" {
  alias  = "secondary"
  region = var.secondary_region
}

# Reads both regional environments' state. Requires environments/primary
# and environments/secondary to have been applied first.
data "terraform_remote_state" "primary" {
  backend = "local"
  config = {
    path = "${path.module}/../environments/primary/terraform.tfstate"
  }
}

data "terraform_remote_state" "secondary" {
  backend = "local"
  config = {
    path = "${path.module}/../environments/secondary/terraform.tfstate"
  }
}

# --- Cross-region private link: lets the secondary region's app tier
# reach the primary region's single RDS instance (§5 of the design doc). ---

resource "aws_vpc_peering_connection" "primary_to_secondary" {
  provider    = aws.primary
  vpc_id      = data.terraform_remote_state.primary.outputs.vpc_id
  peer_vpc_id = data.terraform_remote_state.secondary.outputs.vpc_id
  peer_region = var.secondary_region

  tags = {
    Name = "notes-primary-to-secondary"
  }
}

resource "aws_vpc_peering_connection_accepter" "secondary" {
  provider                  = aws.secondary
  vpc_peering_connection_id = aws_vpc_peering_connection.primary_to_secondary.id
  auto_accept               = true

  tags = {
    Name = "notes-secondary-accepter"
  }
}

resource "aws_route" "primary_to_secondary" {
  provider                  = aws.primary
  route_table_id            = data.terraform_remote_state.primary.outputs.private_route_table_id
  destination_cidr_block    = data.terraform_remote_state.secondary.outputs.vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.primary_to_secondary.id
}

resource "aws_route" "secondary_to_primary" {
  provider                  = aws.secondary
  route_table_id            = data.terraform_remote_state.secondary.outputs.private_route_table_id
  destination_cidr_block    = data.terraform_remote_state.primary.outputs.vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.primary_to_secondary.id

  depends_on = [aws_vpc_peering_connection_accepter.secondary]
}

# RDS lives in its own DB subnet route table (separate from the app
# tier's), which never gets the peering route otherwise. Without this,
# the secondary region's connection attempt reaches RDS fine, but RDS
# has no route back for the reply — it just hangs until the client
# times out, which looks identical to a security group problem.
resource "aws_route" "primary_db_to_secondary" {
  provider                  = aws.primary
  route_table_id            = data.terraform_remote_state.primary.outputs.db_route_table_id
  destination_cidr_block    = data.terraform_remote_state.secondary.outputs.vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.primary_to_secondary.id
}

# --- Global traffic routing: active-active across both regions ---
# Optional — needs a domain you actually control. Without one, test each
# region's ALB DNS name directly (see environment outputs).

resource "aws_route53_health_check" "primary" {
  count             = var.create_dns_records ? 1 : 0
  fqdn              = data.terraform_remote_state.primary.outputs.alb_dns_name
  port              = 80
  type              = "HTTP"
  resource_path     = "/health"
  request_interval  = 30
  failure_threshold = 3

  tags = {
    Name = "notes-primary-health"
  }
}

resource "aws_route53_health_check" "secondary" {
  count             = var.create_dns_records ? 1 : 0
  fqdn              = data.terraform_remote_state.secondary.outputs.alb_dns_name
  port              = 80
  type              = "HTTP"
  resource_path     = "/health"
  request_interval  = 30
  failure_threshold = 3

  tags = {
    Name = "notes-secondary-health"
  }
}

resource "aws_route53_record" "primary" {
  count           = var.create_dns_records ? 1 : 0
  zone_id         = var.hosted_zone_id
  name            = var.record_name
  type            = "A"
  set_identifier  = "primary-${var.primary_region}"
  health_check_id = aws_route53_health_check.primary[0].id

  latency_routing_policy {
    region = var.primary_region
  }

  alias {
    name                   = data.terraform_remote_state.primary.outputs.alb_dns_name
    zone_id                = data.terraform_remote_state.primary.outputs.alb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "secondary" {
  count           = var.create_dns_records ? 1 : 0
  zone_id         = var.hosted_zone_id
  name            = var.record_name
  type            = "A"
  set_identifier  = "secondary-${var.secondary_region}"
  health_check_id = aws_route53_health_check.secondary[0].id

  latency_routing_policy {
    region = var.secondary_region
  }

  alias {
    name                   = data.terraform_remote_state.secondary.outputs.alb_dns_name
    zone_id                = data.terraform_remote_state.secondary.outputs.alb_zone_id
    evaluate_target_health = true
  }
}
