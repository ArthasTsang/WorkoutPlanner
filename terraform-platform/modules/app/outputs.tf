output "alb_arn" {
    description = "ALB arn"
    value       = aws_lb.mwp_alb[*].arn
}

output "alb_dns_name" {
    description = "ALB DNS name"
    value       = aws_lb.mwp_alb[*].dns_name
}

output "cloudfront_origin_header" {
    description = "Cloudfront origin header"
    value       = random_password.cloudfront_secret.result
}

output "ecs_cluster_id" {
  description = "ECS cluster id"
  value       = aws_ecs_cluster.ecs_cluster.id
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.ecs_cluster.name
}

output "docdb_client_launch_template" {
  description = "DocumentDB client launch template"
  value       = aws_launch_template.lt_mwp_workout.name
}