output "log_archive_bucket_name" {
  description = "The name of the log archive bucket"
  value = module.firehose.log_archive_bucket_name
}

output "central_log_destination_arn" {
  description = "The ARN of the central CloudWatch log destination"
  value = module.firehose.central_log_destination_arn
}

output "cloudwatch_role_arn" {
  description = "The ARN of the CloudWatch role"
  value = module.firehose.cloudwatch_role_arn
}

output "firehose_role_arn" {
  description = "The ARN of the firehose role"
  value = module.firehose.firehose_role_arn
}