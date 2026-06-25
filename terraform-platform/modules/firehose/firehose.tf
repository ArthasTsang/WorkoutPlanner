data "aws_s3_bucket" "log_archive_bucket" {
  bucket = "twyat-log-mwp-log-archive-ap-east-1"
}

data "aws_kms_alias" "s3_kms_key" {
  name = "alias/s3"
}

# IAM role for Firehose to put data to S3
resource "aws_iam_role" "firehose_role" {
  name = "${local.name_prefix}-central-log-firehose-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { 
          Service = "firehose.amazonaws.com" 
        }
      }
    ]
  })

  permissions_boundary = "arn:aws:iam::${local.account_id}:policy/${var.project}-platform-scope-boundary-policy"
  # permissions_boundary = "arn:aws:iam::280793169284:policy/mwp-platform-scope-boundary-policy"
}

resource "aws_iam_role_policy" "firehose_s3_policy" {
  name = "${local.name_prefix}-central-log-firehose-s3-policy"
  role = aws_iam_role.firehose_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:PutObject"
        ]
        Resource = [
          "${data.aws_s3_bucket.log_archive_bucket.arn}",
          "${data.aws_s3_bucket.log_archive_bucket.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = [data.aws_kms_alias.s3_kms_key.target_key_arn] 
      }
    ]
  })
}

# Firehose log delivery stream
resource "aws_kinesis_firehose_delivery_stream" "log_stream" {
  name        = "${local.name_prefix}-central-log-delivery-stream"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_role.arn
    bucket_arn = data.aws_s3_bucket.log_archive_bucket.arn
    buffering_size     = 100
    buffering_interval = 300
    compression_format = "GZIP"
    # prefix              = "${var.project}/cloudwatch-logs/account=!{partitionKeyFromQuery:account}/year=!{partitionKeyFromQuery:year}/month=!{partitionKeyFromQuery:month}/day=!{partitionKeyFromQuery:day}/"
    # error_output_prefix = "${var.project}/cloudwatch-logs-errors/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/error=!{firehose:error-output-type}/"
    prefix              = "${var.project}/cloudwatch-logs/account=!{partitionKeyFromQuery:account}/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"
    error_output_prefix = "${var.project}/cloudwatch-logs-errors/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/error=!{firehose:error-output-type}/"
    kms_key_arn = data.aws_kms_alias.s3_kms_key.target_key_arn

    dynamic_partitioning_configuration {
      enabled = "true"
    }

    processing_configuration {
      enabled = true

      # processors {
      #   type = "DataMessageExtraction"
      # }

      # Processor:  Decompression (Converts Raw Binary GZIP into UTF-8 text)
      processors {
        type = "Decompression"
        parameters {
          parameter_name  = "CompressionFormat"
          parameter_value = "GZIP"
        }
        parameters {
          # This tells AWS to perform DataMessageExtraction right before decompressing
          parameter_name  = "DataMessageExtraction"
          parameter_value = "true"
        }
      }
      
      # Processor: Extract CloudWatch metadata
      processors {
        type = "MetadataExtraction"
        parameters {
          parameter_name  = "JsonParsingEngine"
          parameter_value = "JQ-1.6"
        }
        parameters {
          parameter_name  = "MetadataExtractionQuery"
          # This maps your JSON payload keys directly to the variables in your prefix
          # parameter_value = "{account:.owner, year:.timestamp|todatetime|formatdate(\"%Y\"), month:.timestamp|todatetime|formatdate(\"%m\"), day:.timestamp|todatetime|formatdate(\"%d\")}"
          parameter_value = "{account: .owner}"
        }
      }

      # Processor: Append newlines so data queries cleanly in tools like Athena
      processors {
        type = "AppendDelimiterToRecord"
      }
    }
  }
}

# IAM role for CloudWatch to put data to Firehose
resource "aws_iam_role" "cloudwatch_to_firehose_role" {
  name = "${local.name_prefix}-central-log-cloudwatch-to-firehose-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { 
          Service = "logs.amazonaws.com" 
        }
      }
    ]
  })

  permissions_boundary = "arn:aws:iam::${local.account_id}:policy/${var.project}-platform-scope-boundary-policy"
  # permissions_boundary = "arn:aws:iam::280793169284:policy/mwp-platform-scope-boundary-policy"
}

resource "aws_iam_role_policy" "cloudwatch_to_firehose_policy" {
  name = "${local.name_prefix}-central-cloudwatch-to-firehose-policy"
  role = aws_iam_role.cloudwatch_to_firehose_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "firehose:PutRecord", 
          "firehose:PutRecordBatch"
        ]
        Resource = [aws_kinesis_firehose_delivery_stream.log_stream.arn]
      }
    ]
  })
}

# CloudWatch Log Destination to route logs to Firehose
resource "aws_cloudwatch_log_destination" "central_log_destination" {
  name       = "${local.name_prefix}-central-log-destination"
  role_arn   = aws_iam_role.cloudwatch_to_firehose_role.arn
  target_arn = aws_kinesis_firehose_delivery_stream.log_stream.arn
}

resource "aws_cloudwatch_log_destination_policy" "central_destination_policy" {
  destination_name = aws_cloudwatch_log_destination.central_log_destination.name

  access_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowSourceAccounts"
        Effect = "Allow"
        Principal = {
          AWS = var.source_account_ids
        }
        Action    = [
          "logs:PutSubscriptionFilter",
          # Required for dev/uat/prod account to allow account-wide policy
          "logs:PutAccountPolicy"
        ]
        Resource = [aws_cloudwatch_log_destination.central_log_destination.arn]
      }
    ]
  })

  depends_on = [aws_cloudwatch_log_destination.central_log_destination]
}

# Share central destination ARN via SSM Parameter
resource "aws_ssm_parameter" "shared_destination" {
  name        = "/platform/logging/central_log_destination_arn"
  type        = "String"
   # Must be Advanced to allow RAM sharing
  tier        = "Advanced"
  value       = aws_cloudwatch_log_destination.central_log_destination.arn
  description = "Shared cross-account CloudWatch log destination endpoint"
}

# Create RAM Resource Share
resource "aws_ram_resource_share" "logging_share" {
  name                      = "${local.name_prefix}-shared-logging-parameters"
  allow_external_principals = false
}

resource "aws_ram_resource_association" "ssm_association" {
  resource_arn       = aws_ssm_parameter.shared_destination.arn
  resource_share_arn = aws_ram_resource_share.logging_share.arn
}

resource "aws_ram_principal_association" "account_association" {
  for_each           = toset(var.source_account_ids)
  principal          = each.value
  resource_share_arn = aws_ram_resource_share.logging_share.arn
}