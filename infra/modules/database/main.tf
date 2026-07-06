resource "random_password" "db" {
  length  = 24
  special = false
}

resource "aws_db_subnet_group" "this" {
  name_prefix = "${var.name_prefix}-db-"
  subnet_ids  = var.db_subnet_ids

  tags = {
    Name = "${var.name_prefix}-db-subnet-group"
  }
}

# Single instance, Multi-AZ disabled, no read replicas — requirement 3.
resource "aws_db_instance" "this" {
  identifier_prefix      = "${var.name_prefix}-"
  engine                 = "postgres"
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  allocated_storage      = var.allocated_storage
  db_name                = var.db_name
  username               = var.db_username
  password               = random_password.db.result
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.db_sg_id]

  multi_az = false

  publicly_accessible     = false
  skip_final_snapshot     = true
  backup_retention_period = var.backup_retention_period

  tags = {
    Name = "${var.name_prefix}-db"
  }
}

resource "aws_secretsmanager_secret" "db_credentials" {
  name_prefix = "${var.name_prefix}-db-credentials-"

  dynamic "replica" {
    for_each = var.replica_region != "" ? [var.replica_region] : []
    content {
      region = replica.value
    }
  }
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    database_url = "postgresql+psycopg2://${var.db_username}:${random_password.db.result}@${aws_db_instance.this.address}:${aws_db_instance.this.port}/${var.db_name}"
  })
}
