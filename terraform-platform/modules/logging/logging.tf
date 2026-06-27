data "aws_ssm_parameter" "central_log_destination" {
  # ARN Format: arn:aws:ssm:<REGION>:<LOG_ACCOUNT_ID>:parameter/<NAME>
  name = "arn:aws:ssm:${var.region}:${var.log_account_id}:parameter/${var.project}/logging/${var.env}/central_log_destination_arn"
}

# Run this inside the Dev, UAT, or Prod account root configuration
resource "aws_cloudwatch_log_account_policy" "all_logs_to_central" {
  policy_name    = "ShipAllLogsToCentralAccount"
  policy_type    = "SUBSCRIPTION_FILTER_POLICY"
  
  policy_document = jsonencode({
    DestinationArn = data.aws_ssm_parameter.central_log_destination.value
    # Forward everything
    FilterPattern  = "" 
	  Distribution   = "Random"
  })
}