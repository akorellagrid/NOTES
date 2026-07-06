resource "aws_security_group" "alb" {
  name_prefix = "${var.name_prefix}-alb-"
  vpc_id      = var.vpc_id
  description = "Internet-facing ALB - the only public entry point in this region"

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-alb-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "app" {
  name_prefix = "${var.name_prefix}-app-"
  vpc_id      = var.vpc_id
  description = "App instances - private subnets only, reachable only from the ALB"

  ingress {
    description     = "App traffic from the ALB only"
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-app-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Database security group only exists in the primary region, which hosts the
# single RDS instance. It's opened by CIDR (not security-group reference)
# because the secondary region's app tier lives in a peered VPC — SG-to-SG
# references don't cross regions/VPCs, only CIDR-based rules do.
resource "aws_security_group" "db" {
  count       = var.create_db_sg ? 1 : 0
  name_prefix = "${var.name_prefix}-db-"
  vpc_id      = var.vpc_id
  description = "RDS instance - reachable only from app-tier subnets in both regions"

  ingress {
    description = "Postgres from app-tier subnets (both regions)"
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = var.db_allowed_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-db-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}
