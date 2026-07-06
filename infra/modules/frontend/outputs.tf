output "alb_dns_name" {
  value = aws_lb.frontend.dns_name
}

output "alb_zone_id" {
  value = aws_lb.frontend.zone_id
}

output "alb_arn_suffix" {
  value = aws_lb.frontend.arn_suffix
}

output "target_group_arn_suffix" {
  value = aws_lb_target_group.frontend.arn_suffix
}

output "asg_name" {
  value = aws_autoscaling_group.frontend.name
}
