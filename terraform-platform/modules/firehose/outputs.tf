output "log_archive_bucket_name" {
  description = "The name of the log archive bucket"
  value = data.aws_s3_bucket.log_archive_bucket.bucket
}

output "central_log_destination_arn" {
  description = "The ARN of the central CloudWatch log destination"
  value = aws_cloudwatch_log_destination.central_log_destination.arn
}

output "cloudwatch_role_arn" {
  description = "The ARN of the CloudWatch role"
  value = aws_iam_role.cloudwatch_to_firehose_role.arn
}

output "firehose_role_arn" {
  description = "The ARN of the firehose role"
  value = aws_iam_role.firehose_role.arn
}