output "cloudwatch_log_account_policy" {
    description = "The ARN of the CloudWatch log account policy"
    value = aws_cloudwatch_log_account_policy.all_logs_to_central.policy_name
}