output "vpc_id" {
  value = aws_vpc.this.id
}

output "vpc_cidr" {
  value = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "db_subnet_ids" {
  value = aws_subnet.db[*].id
}

output "private_route_table_id" {
  value = aws_route_table.private.id
}

output "db_route_table_id" {
  description = "The DB subnet group's own route table (separate from the app tier's) — RDS's replies need a route back to any peered region, or connections from there hang until they time out."
  value       = length(aws_route_table.db) > 0 ? aws_route_table.db[0].id : null
}

output "nat_instance_id" {
  value = aws_instance.nat.id
}
