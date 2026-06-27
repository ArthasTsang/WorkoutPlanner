output "demo_log_archive_bucket_name" {
  description = "The name of the log archive bucket"
  value = module.demo_firehose.log_archive_bucket_name
}

output "demo_central_log_destination_arn" {
  description = "The ARN of the central CloudWatch log destination"
  value = module.demo_firehose.central_log_destination_arn
}

output "demo_cloudwatch_role_arn" {
  description = "The ARN of the CloudWatch role"
  value = module.demo_firehose.cloudwatch_role_arn
}

output "demo_firehose_role_arn" {
  description = "The ARN of the firehose role"
  value = module.demo_firehose.firehose_role_arn
}

output "dev_log_archive_bucket_name" {
  description = "The name of the log archive bucket"
  value = module.dev_firehose.log_archive_bucket_name
}

output "dev_central_log_destination_arn" {
  description = "The ARN of the central CloudWatch log destination"
  value = module.dev_firehose.central_log_destination_arn
}

output "dev_cloudwatch_role_arn" {
  description = "The ARN of the CloudWatch role"
  value = module.dev_firehose.cloudwatch_role_arn
}

output "dev_firehose_role_arn" {
  description = "The ARN of the firehose role"
  value = module.dev_firehose.firehose_role_arn
}

output "uat_log_archive_bucket_name" {
  description = "The name of the log archive bucket"
  value = module.uat_firehose.log_archive_bucket_name
}

output "uat_central_log_destination_arn" {
  description = "The ARN of the central CloudWatch log destination"
  value = module.uat_firehose.central_log_destination_arn
}

output "uat_cloudwatch_role_arn" {
  description = "The ARN of the CloudWatch role"
  value = module.uat_firehose.cloudwatch_role_arn
}

output "uat_firehose_role_arn" {
  description = "The ARN of the firehose role"
  value = module.uat_firehose.firehose_role_arn
}

output "prod_log_archive_bucket_name" {
  description = "The name of the log archive bucket"
  value = module.prod_firehose.log_archive_bucket_name
}

output "prod_central_log_destination_arn" {
  description = "The ARN of the central CloudWatch log destination"
  value = module.prod_firehose.central_log_destination_arn
}

output "prod_cloudwatch_role_arn" {
  description = "The ARN of the CloudWatch role"
  value = module.prod_firehose.cloudwatch_role_arn
}

output "prod_firehose_role_arn" {
  description = "The ARN of the firehose role"
  value = module.prod_firehose.firehose_role_arn
}