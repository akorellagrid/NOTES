output "db_endpoint" {
  value = aws_db_instance.this.address
}

output "db_port" {
  value = aws_db_instance.this.port
}

output "db_instance_id" {
  description = "The DB instance identifier (e.g. notes-primary-...), not the opaque .id resource ID — CloudWatch's DBInstanceIdentifier dimension needs this exact value, not aws_db_instance.this.id."
  value       = aws_db_instance.this.identifier
}

output "secret_arn" {
  description = "Secrets Manager ARN holding the DATABASE_URL — pass this to the compute module in both regions"
  value       = aws_secretsmanager_secret.db_credentials.arn
}
