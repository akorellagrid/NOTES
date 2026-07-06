output "aws_region" {
  value = var.aws_region
}

output "vpc_id" {
  value = module.network.vpc_id
}

output "vpc_cidr" {
  value = module.network.vpc_cidr
}

output "private_route_table_id" {
  value = module.network.private_route_table_id
}

output "alb_dns_name" {
  value = module.compute.alb_dns_name
}

output "frontend_alb_dns_name" {
  value = module.frontend.alb_dns_name
}

output "alb_zone_id" {
  value = module.compute.alb_zone_id
}
