data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["*-${var.project}-vpc"]
  }
}

data "aws_subnets" "db_subnet" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  filter {
    name   = "tag:Name"
    values = ["*db-subnet*"]
  }
}

data "aws_security_group" "app_sg" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  filter {
    name   = "tag:Name"
    values = ["*app-sg"]
  }
}

# DB Security Group
resource "aws_security_group" "db_sg" {
  name        = "${local.name_prefix}-db-sg"
  description = "Allows database traffic only from the App tier"
  vpc_id      = data.aws_vpc.main.id

  tags = { 
    Name = "${local.name_prefix}-db-sg" 
  }
}

resource "aws_vpc_security_group_ingress_rule" "db_sg_ingress_docdb" {
  for_each = {
    "app_tier" = "${var.network_account_id}/${data.aws_security_group.app_sg.id}",
    "rotation" = aws_security_group.rotation_lambda_sg.id
  }

  security_group_id            = aws_security_group.db_sg.id
  referenced_security_group_id = each.value
  from_port                    = 27017
  to_port                      = 27017
  ip_protocol                  = "tcp"
  description                  = "Allow inbound DocumentDB traffic from app tier"
}

resource "aws_vpc_security_group_egress_rule" "db_sg_egress_all" {
  security_group_id = aws_security_group.db_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow all outbound traffic"
}

# DocumentDB Subnet Group
resource "aws_docdb_subnet_group" "docdb_subnet_group" {
  name       = "${local.name_prefix}-docdb-subnet-group"
  subnet_ids = data.aws_subnets.db_subnet.ids

  tags = {
    Name = "${local.name_prefix}-docdb-subnet-group"
  }
}

# Generate a secure, random password
resource "random_password" "docdb_password" {
  length           = 24
  special          = true
  # Exclude characters that often break database connection strings
  override_special = "!#$%&*()-_=+[]{}<>:?" 
}

# DocumentDB Cluster
resource "aws_docdb_cluster" "docdb" {
  cluster_identifier = "${local.name_prefix}-docdb-cluster"
  engine = "docdb"
  master_username = "mwp"
  master_password = random_password.docdb_password.result
  storage_encrypted       = true  
  kms_key_id          = var.kms_key_arn
  snapshot_identifier  = var.is_create_from_snapshot ? var.snapshot_id : null
  backup_retention_period = 7
  preferred_backup_window = "17:00-18:00"
  deletion_protection = false
  skip_final_snapshot = true 
  db_subnet_group_name = aws_docdb_subnet_group.docdb_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  tags = {
    Name = "${local.name_prefix}-docdb-cluster"
  }
}

# DocumentDB Cluster Instances (1 Primary + 1 Replica)
resource "aws_docdb_cluster_instance" "cluster_instances" {
  count              = var.requested_db_instance_count
  identifier         = "my-docdb-instance-${count.index}"
  cluster_identifier = aws_docdb_cluster.docdb.id
  instance_class     = "db.t3.medium"
}

# Store the DB password and connection details in Secrets Manager
resource "aws_secretsmanager_secret" "docdb_secret" {
  name = "/${var.project}/docdb/connectionDetails"
  recovery_window_in_days = var.env == "prod" ? 30 : 0
}

resource "aws_secretsmanager_secret_version" "docdb_secret_val" {
  secret_id = aws_secretsmanager_secret.docdb_secret.id
  secret_string = jsonencode({
    engine = "mongo"
    dbClusterIdentifier = aws_docdb_cluster.docdb.cluster_identifier
    host = aws_docdb_cluster.docdb.endpoint
    port     = aws_docdb_cluster.docdb.port
    username = aws_docdb_cluster.docdb.master_username
    password = random_password.docdb_password.result
    dbname = var.db_name
    authSource = var.db_name
    ssl = "true"
  })
}

# Deploy Lambda application for password rotation
resource "aws_security_group" "rotation_lambda_sg" {
  name        = "${local.name_prefix}-docdb-rotation-lambda-sg"
  description = "Local security group for cross-account DocumentDB rotation function"
  vpc_id      = data.aws_vpc.main.id

  # Outbound access: The Lambda needs to reach DocumentDB on 27017 and Secrets Manager via 443
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-docdb-rotation-lambda-sg"
  }
}

# data "aws_serverlessapplicationrepository_application" "password_rotator" {
#   application_id = "arn:aws:serverlessrepo:us-east-1:297356227824:applications/SecretsManagerMongoDBRotationSingleUser"
# }

# resource "aws_serverlessapplicationrepository_cloudformation_stack" "db_rotator" {
#   name           = "docdb-hosted-rotation-stack"
#   application_id = data.aws_serverlessapplicationrepository_application.password_rotator.application_id
#   semantic_version = data.aws_serverlessapplicationrepository_application.password_rotator.semantic_version
#   capabilities = data.aws_serverlessapplicationrepository_application.password_rotator.required_capabilities

#   parameters = {
#     endpoint            = "https://secretsmanager.${var.region}.amazonaws.com"
#     functionName        = "docdb-rotation-lambda"
#     vpcSubnetIds        = join(",", data.aws_subnets.db_subnet.ids)
#     vpcSecurityGroupIds = aws_security_group.rotation_lambda_sg.id
#     # secretId            = aws_secretsmanager_secret.docdb_secret.id
#   }
# }

# resource "aws_lambda_permission" "allow_secretsmanager" {
#   statement_id  = "AllowExecutionFromSecretsManager"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_serverlessapplicationrepository_cloudformation_stack.db_rotator.outputs.RotationLambdaARN
#   principal     = "secretsmanager.amazonaws.com"
# }

# Locate the code artifiacts in S3
data "aws_s3_object" "rotation_zip" {
  bucket = "${local.account_alias}-${var.project}-artifact-${var.region}"
  key    = "lambda/docdbPwdRotation.zip"
}

# Create Lambda function role
resource "aws_iam_role" "rotation_lambda_role" {
  name                 = "${local.name_prefix}-docdb-rotation-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = [
            "lambda.amazonaws.com"
          ]
        }
      }
    ]
  })

  permissions_boundary = "arn:aws:iam::${local.account_id}:policy/${var.project}-platform-scope-boundary-policy"
}

resource "aws_iam_policy" "rotation_lambda_policy" {
  name = "${local.name_prefix}-docdb-rotation-lambda-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetRandomPassword"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetSecretValue",
          "secretsmanager:PutSecretValue",
          "secretsmanager:UpdateSecretVersionStage"
        ]
        Resource = "arn:aws:secretsmanager:${var.region}:${local.account_id}:secret:*" 
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DetachNetworkInterface"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${var.region}:${local.account_id}:log-group:/aws/lambda/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_rotation_policy" {
  role       = aws_iam_role.rotation_lambda_role.name
  policy_arn = aws_iam_policy.rotation_lambda_policy.arn
}

# Deploy the Lambda Function
resource "aws_lambda_function" "db_rotator" {
  function_name    = "${local.name_prefix}-docdb-rotation-lambda"
  role             = aws_iam_role.rotation_lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.13"
  timeout          = 30 # Rotation scripts can take time to test connections

  s3_bucket         = data.aws_s3_object.rotation_zip.bucket
  s3_key            = data.aws_s3_object.rotation_zip.key
  # s3_object_version = data.aws_s3_object.rotation_zip.version_id
  source_code_hash = data.aws_s3_object.rotation_zip.etag

  vpc_config {
    subnet_ids         = data.aws_subnets.db_subnet.ids
    security_group_ids = [aws_security_group.rotation_lambda_sg.id]
  }

  # AWS Secrets Manager passes the Secrets Manager endpoint configuration via environment variables to the rotation script
  environment {
    variables = {
      SECRETS_MANAGER_ENDPOINT = "https://secretsmanager.${var.region}.amazonaws.com"
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.attach_rotation_policy
  ]
}

# Authorize Secrets Manager to invoke Lambda
resource "aws_lambda_permission" "allow_secrets_manager" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.db_rotator.function_name
  principal     = "secretsmanager.amazonaws.com"
}

resource "aws_secretsmanager_secret_rotation" "docdb_rotation" {
  secret_id           = aws_secretsmanager_secret.docdb_secret.id
  rotation_lambda_arn = aws_lambda_function.db_rotator.arn

  rotation_rules {
    # format: cron(Minutes Hours Day-of-month Month Day-of-week Year)
    # 18:00 UTC matches exactly 02:00 AM HKT.
    # Runs on the 1st day of every 3rd month (Jan, Apr, Jul, Oct).
    schedule_expression = "cron(0 18 1 1/3 ? *)"
    duration            = "2h"
  }
}