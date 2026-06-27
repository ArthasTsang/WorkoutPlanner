output "ecs_task_id" {
    description = "ECS task id"
    value       = module.service.ecs_task_id
}

output "ecs_task_arn" {
    description = "ECS task ARN"
    value       = module.service.ecs_task_arn
}

output "ecs_execution_role" {
    description = "ECS execution role ARN"
    value       = module.service.ecs_execution_role
}

output "ecs_task_role" {
    description = "ECS task role ARN"
    value       = module.service.ecs_task_role
}

output "ecs_service_name" {
    description = "ECS service name"
    value       = module.service.ecs_service_name[*]
}

output "ecs_service_arn" {
    description = "ECS service ARN"
    value       = module.service.ecs_service_arn[*]
}

output "blue_tg_name" {
    description = "ECS blue target group name"
    value       = module.service.blue_tg_name[*]
}

output "green_tg_name" {
    description = "ECS green target group name"
    value       = module.service.green_tg_name[*]
}

output "ecs_app_arn" {
    description = "ECS application ARN"
    value       = module.deploy.ecs_app_arn
}

output "ecs_dg_arn" {
    description = "ECS deployment group ARN"
    value       = module.deploy.ecs_dg_arn[*]
}

output "codedeploy_role_arn" {
    description = "CodeDeploy role ARN"
    value       = module.deploy.codedeploy_role_arn
}