resource "aws_ecr_repository" "app" {
  name                 = var.repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.name_prefix}-ecr"
  }
}

data "aws_caller_identity" "current" {}

resource "aws_ecr_replication_configuration" "app" {
  count = var.replica_region != "" ? 1 : 0

  replication_configuration {
    rule {
      destination {
        region      = var.replica_region
        registry_id = data.aws_caller_identity.current.account_id
      }
    }
  }
}
