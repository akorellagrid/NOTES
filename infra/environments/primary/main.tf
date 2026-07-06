terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "notes-capstone"
      Environment = "primary"
      ManagedBy   = "terraform"
    }
  }
}

locals {
  name_prefix = "notes-primary"
}

module "network" {
  source = "../../modules/network"

  name_prefix          = local.name_prefix
  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  db_subnet_cidrs      = var.db_subnet_cidrs
}

module "security" {
  source = "../../modules/security"

  name_prefix  = local.name_prefix
  vpc_id       = module.network.vpc_id
  create_db_sg = true
  db_allowed_cidrs = [
    var.vpc_cidr,
    var.secondary_vpc_cidr,
  ]
}

module "registry" {
  source = "../../modules/registry"

  name_prefix    = local.name_prefix
  replica_region = var.secondary_region
}

module "database" {
  source = "../../modules/database"

  name_prefix    = local.name_prefix
  db_subnet_ids  = module.network.db_subnet_ids
  db_sg_id       = module.security.db_sg_id
  replica_region = var.secondary_region
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
  container_image    = "${module.registry.repository_url}:${var.container_image_tag}"
  db_secret_arn      = module.database.secret_arn
  certificate_arn    = var.certificate_arn
}

# --- Frontend tier: the actual browsable web app (nginx serving the
# built static assets, reverse-proxying /api/* to the backend ALB
# above). A separate ALB/ASG pair, not part of the Part 4 requirements
# themselves, but needed to have an actual page to open in a browser
# instead of just the JSON API. ---

resource "aws_ecr_repository" "frontend" {
  name                 = "notes-frontend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${local.name_prefix}-frontend-ecr"
  }
}

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
  container_image    = "${aws_ecr_repository.frontend.repository_url}:${var.container_image_tag}"
  api_upstream       = "${module.compute.alb_dns_name}:80"
  certificate_arn    = var.certificate_arn
}

module "monitoring" {
  source = "../../modules/monitoring"

  name_prefix        = local.name_prefix
  aws_region         = var.aws_region
  notification_email = var.notification_email
  budget_limit_usd   = var.budget_limit_usd
  stop_trigger_usd   = var.stop_trigger_usd

  backend_alb_arn_suffix = module.compute.alb_arn_suffix
  backend_tg_arn_suffix  = module.compute.target_group_arn_suffix
  backend_asg_name       = module.compute.asg_name

  frontend_alb_arn_suffix = module.frontend.alb_arn_suffix
  frontend_tg_arn_suffix  = module.frontend.target_group_arn_suffix
  frontend_asg_name       = module.frontend.asg_name

  db_instance_id  = module.database.db_instance_id
  nat_instance_id = module.network.nat_instance_id
}
