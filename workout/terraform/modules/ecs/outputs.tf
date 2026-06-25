output "ecs_task_arn" {
    description = "ECS task ARN"
    value       = aws_ecs_task_definition.task.arn
}

output "ecs_service_arn" {
    description = "ECS service ARN"
    value       = aws_ecs_service.service[*].arn
}

output "ecs_service_name" {
    description = "ECS service name"
    value       = aws_ecs_service.service[*].name
}

output "blue_tg_name" {
    description = "ECS blue target group name"
    value       = aws_lb_target_group.blue_tg[*].name
}

output "green_tg_name" {
    description = "ECS green target group name"
    value       = aws_lb_target_group.green_tg[*].name
}
