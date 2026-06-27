# Create DLQ for EventBridge Scheduler
resource "aws_sqs_queue" "scheduler_dlq" {
  name = "my-eventbridge-scheduler-dlq"
}

# Create IAM role for EventBridge Scheduler
resource "aws_iam_role" "scheduler_role" {
  name = "${local.name_prefix}-${var.region}-eventbridge-scheduler-docdb-shutdown-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { 
          Service = "scheduler.amazonaws.com" 
        }
        Action    = "sts:AssumeRole"
      }
    ]
  })

  permissions_boundary = "arn:aws:iam::${local.account_id}:policy/${var.project}-platform-${var.region}-scope-boundary-policy"
}

resource "aws_iam_policy" "scheduler_policy" {
  name        = "${local.name_prefix}-${var.region}-eventbridge-scheduler-docdb-shutdown-policy"
  description = "Allows EventBridge Scheduler to stop DocumentDB clusters"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "rds:StartDBCluster",
          "rds:StopDBCluster"
        ]
        Resource = var.docdb_cluster_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "scheduler_attach" {
  role       = aws_iam_role.scheduler_role.name
  policy_arn = aws_iam_policy.scheduler_policy.arn
}

resource "aws_iam_policy" "scheduler_dlq_policy" {
  name        = "${local.name_prefix}-${var.region}-eventbridge-scheduler-dlq-publish-policy"
  description = "Allows EventBridge Scheduler to route failed executions to SQS DLQ"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.scheduler_dlq.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_dlq_policy" {
  role       = aws_iam_role.scheduler_role.name
  policy_arn = aws_iam_policy.scheduler_dlq_policy.arn
}

resource "aws_iam_policy" "scheduler_logging_policy" {
  name        = "${local.name_prefix}-${var.region}-eventbridge-scheduler-logging-policy"
  description = "Allows EventBridge Scheduler to write logs to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_logging" {
  role       = aws_iam_role.scheduler_role.name
  policy_arn = aws_iam_policy.scheduler_logging_policy.arn
}

# Deploy the EventBridge Scheduler to stop DocumentDB clusters
resource "aws_scheduler_schedule" "docdb_shutdown" {
  name        = "stop-docdb-cluster-daily"
  group_name  = "default"
  description = "Triggers a shutdown of DocumentDB cluster every day at 2:00 AM HK time"

  schedule_expression          = "cron(00 20 * * ? *)"
  schedule_expression_timezone = "Asia/Hong_Kong"
  flexible_time_window {
    # Ensures the action executes exactly without random delays
    mode = "OFF"
  }

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:docdb:stopDBCluster"
    role_arn = aws_iam_role.scheduler_role.arn
    
    dead_letter_config {
      arn = aws_sqs_queue.scheduler_dlq.arn
    }

    retry_policy {
      maximum_event_age_in_seconds = 3600
      maximum_retry_attempts = 1
    }

    input = jsonencode({
      DbClusterIdentifier = var.docdb_cluster_id
    })
  }
}

# Deploy the EventBridge Scheduler to start DocumentDB clusters
resource "aws_scheduler_schedule" "docdb_startup" {
  count = var.is_startup_required ? 1 : 0

  name        = "start-docdb-cluster-daily"
  group_name  = "default"
  description = "Triggers a startup of DocumentDB cluster every day at 2:00 AM HK time"

  schedule_expression          = "cron(00 08 * * ? *)"
  schedule_expression_timezone = "Asia/Hong_Kong"
  flexible_time_window {
    # Ensures the action executes exactly without random delays
    mode = "OFF"
  }

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:docdb:startDBCluster"
    role_arn = aws_iam_role.scheduler_role.arn
    
    dead_letter_config {
      arn = aws_sqs_queue.scheduler_dlq.arn
    }

    retry_policy {
      maximum_event_age_in_seconds = 3600
      maximum_retry_attempts = 1
    }

    input = jsonencode({
      DbClusterIdentifier = var.docdb_cluster_id
    })
  }
}