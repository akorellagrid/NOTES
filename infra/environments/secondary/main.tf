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
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "notes-capstone"
      Environment = "secondary"
      ManagedBy   = "terraform"
    }
  }
}

locals {
  name_prefix = "notes-secondary"
}

# Reads the primary region's state to find its ECR repo and DB secret,
# so this environment can be applied second without manual copy/paste.
# Requires environments/primary to have been applied first.
data "terraform_remote_state" "primary" {
  backend = "local"

  config = {
    path = "${path.module}/../primary/terraform.tfstate"
  }
}

module "network" {
  source = "../../modules/network"

  name_prefix          = local.name_prefix
  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  # No db_subnet_cidrs: this region has no local database, by design —
  # see docs/aws-architecture.md §5 for the cross-region trade-off.
}

module "security" {
  source = "../../modules/security"

  name_prefix  = local.name_prefix
  vpc_id       = module.network.vpc_id
  create_db_sg = false
}

# Same ECR repository as primary, replicated into this region — pull
# locally instead of across regions. No separate repository resource:
# ECR replication is registry-level and was configured in environments/primary.
locals {
  container_image = replace(
    data.terraform_remote_state.primary.outputs.ecr_repository_url,
    data.terraform_remote_state.primary.outputs.aws_region,
    var.aws_region
  )

  # Same trick for the replicated Secrets Manager secret: same account
  # and secret name/suffix, only the region segment of the ARN differs.
  db_secret_arn = replace(
    data.terraform_remote_state.primary.outputs.db_secret_arn,
    data.terraform_remote_state.primary.outputs.aws_region,
    var.aws_region
  )

  # Same trick again for the replicated frontend image.
  frontend_container_image = replace(
    data.terraform_remote_state.primary.outputs.frontend_ecr_repository_url,
    data.terraform_remote_state.primary.outputs.aws_region,
    var.aws_region
  )
}

module "compute" {
  source = "../../modules/compute"

  name_prefix        = local.name_prefix
  vpc_id             = module.network.vpc_id
  aws_region         = var.aws_region
  public_subnet_ids  = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids
  alb_sg_id          = module.security.alb_sg_id
  app_sg_id          = module.security.app_sg_id
  instance_type      = var.instance_type
  min_size           = var.min_size
  max_size           = var.max_size
  desired_capacity   = var.desired_capacity
  container_image    = "${local.container_image}:${var.container_image_tag}"
  db_secret_arn      = local.db_secret_arn
  certificate_arn    = var.certificate_arn
}

# Frontend tier, mirroring environments/primary — proxies /api/* to this
# region's own backend ALB (module.compute above), keeping app-tier
# traffic in-region even though the database call still crosses regions.
module "frontend_security" {
  source = "../../modules/security"

  name_prefix  = "${local.name_prefix}-frontend"
  vpc_id       = module.network.vpc_id
  app_port     = 80
  create_db_sg = false
}

module "frontend" {
  source = "../../modules/frontend"

  name_prefix        = local.name_prefix
  vpc_id             = module.network.vpc_id
  aws_region         = var.aws_region
  public_subnet_ids  = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids
  alb_sg_id          = module.frontend_security.alb_sg_id
  app_sg_id          = module.frontend_security.app_sg_id
  instance_type      = var.instance_type
  min_size           = var.min_size
  max_size           = var.max_size
  desired_capacity   = var.desired_capacity
  container_image    = "${local.frontend_container_image}:${var.container_image_tag}"
  api_upstream       = "${module.compute.alb_dns_name}:80"
  certificate_arn    = var.certificate_arn
}
