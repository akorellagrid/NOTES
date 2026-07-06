output "peering_connection_id" {
  value = aws_vpc_peering_connection.primary_to_secondary.id
}

output "primary_alb_dns_name" {
  value = data.terraform_remote_state.primary.outputs.alb_dns_name
}

output "secondary_alb_dns_name" {
  value = data.terraform_remote_state.secondary.outputs.alb_dns_name
}
