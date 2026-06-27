output "ecs_app_arn" {
    description = "ECS application ARN"
    value       = aws_codedeploy_app.ecs_app.arn
}

output "ecs_dg_arn" {
    description = "ECS deployment group ARN"
    value       = aws_codedeploy_deployment_group.ecs_dg[*].arn
}

output "codedeploy_role_arn" {
    description = "CodeDeploy role ARN"
    value       = aws_iam_role.cd_service_role.arn
}