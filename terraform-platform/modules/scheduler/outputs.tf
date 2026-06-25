output "start_db_scheduler_name" {
  description = "Start db cluster schedule name"
  value       = aws_scheduler_schedule.docdb_startup[*].name
}

output "start_db_scheduler_cron" {
  description = "Start db cluster cron expression"
  value       = aws_scheduler_schedule.docdb_startup[*].schedule_expression
}

output "stop_db_scheduler_name" {
  description = "Stop db cluster schedule name"
  value       = aws_scheduler_schedule.docdb_shutdown.name
}

output "stop_db_scheduler_cron" {
  description = "Stop db cluster cron expression"
  value       = aws_scheduler_schedule.docdb_shutdown[*].schedule_expression
}