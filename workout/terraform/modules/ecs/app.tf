data "aws_ssm_parameter" "alb_listener_arn" {
  name = "/platform/services/alb_listener_arn"
}

data "aws_ssm_parameter" "cloudfront_origin_header" {
  name = "/platform/services/cloudfront_origin_header"
}

data "aws_ssm_parameter" "ecs_cluster_id" {
  name = "/platform/services/ec_cluster_id"
}

data "aws_ssm_parameter" "ecs_cluster_name" {
  name = "/platform/services/ec_cluster_name"
}

data "aws_iam_policy" "ecs_service_role" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy" "xray_write" {
  arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

# CloudWatch log group
resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/aws/ecs/${local.full_service_name}-app"
  retention_in_days = 3
}

resource "aws_cloudwatch_log_group" "ecs_adot_log_group" {
  name              = "/aws/ecs/${local.full_service_name}-app-adot"
  retention_in_days = 3
}

# ECS task execution role
resource "aws_iam_role" "ecs_execution_role" {
  name = "${local.full_service_name}-${var.region}-ecs-execution-role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ecs-tasks.amazonaws.com"
            },
            "Action": "sts:AssumeRole",
            "Condition": {
                "StringEquals": {
                    "aws:SourceAccount": "${local.account_id}"
                },
                "ArnLike": {
                    "aws:SourceArn": "arn:aws:ecs:${var.region}:${local.account_id}:*"
                }
            }
        }
    ]
  })

  permissions_boundary = "arn:aws:iam::${local.account_id}:policy/${local.full_service_name}-${var.region}-scope-boundary-policy"
}

resource "aws_iam_role_policy" "ecs_execution_secrets_policy" {
  name = "${local.full_service_name}-${var.region}-ecs-execution-policy"
  role = aws_iam_role.ecs_execution_role.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetSecretValue"
            ],
            "Resource": [
                "arn:aws:secretsmanager:${var.region}:${local.account_id}:secret:/${var.project}/docdb/connectionDetails-*"
            ]
        }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = data.aws_iam_policy.ecs_service_role.arn
}

# ECS task role
resource "aws_iam_role" "ecs_task_role" {
  name = "${local.full_service_name}-${var.region}-ecs-task-role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ecs-tasks.amazonaws.com"
            },
            "Action": "sts:AssumeRole",
            "Condition": {
                "StringEquals": {
                    "aws:SourceAccount": "${local.account_id}"
                },
                "ArnLike": {
                    "aws:SourceArn": "arn:aws:ecs:${var.region}:${local.account_id}:*"
                }
            }
        }
    ]
  })

  permissions_boundary = "arn:aws:iam::${local.account_id}:policy/${local.full_service_name}-${var.region}-scope-boundary-policy"
}

resource "aws_iam_role_policy_attachment" "task_xray" {
  role       = aws_iam_role.ecs_task_role.id
  policy_arn = data.aws_iam_policy.xray_write.arn
}

resource "aws_iam_role_policy" "ecs_task_policy" {
  name = "${local.full_service_name}-${var.region}-ecs-task-policy"
  role = aws_iam_role.ecs_task_role.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetSecretValue"
            ],
            "Resource": [
                "arn:aws:secretsmanager:${var.region}:${local.account_id}:secret:/${var.project}/docdb/connectionDetails-*"
            ]
        },
        {
            "Sid": "AllowDocumentDBIAMAuth",
            "Effect": "Allow",
            "Action": [
                "rds-db:connect"
            ],
            "Resource": [
                "arn:aws:rds:${var.region}:${local.account_id}:dbuser:${var.project}-docdb-cluster/*"
            ]
        }
    ]
  })
}

# ECS task definition
resource "aws_ecs_task_definition" "task" {
  family                   = "${local.full_service_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "${local.full_service_name}-container"
      # TODO
      image     = "${local.account_id}.dkr.ecr.${var.region}.amazonaws.com/${local.full_service_name}:latest"
      essential = true
      portMappings = [{
        name          = "8092"
        containerPort = 8092
        portProtocol  = "tcp"
        hostPort      = 8092
        appProtocol   = "http"
      }]

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:8092/planner/workout/health || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60 # Crucial: gives your app time to start up before checking
      }

      environment = [
        {
          name  = "profile"
          value = "${var.env}"
        },
        {
          name  = "OTEL_EXPORTER_OTLP_ENDPOINT"
          value = "http://localhost:4317"
        },
        {
          name  = "OTEL_EXPORTER_OTLP_PROTOCOL"
          value = "grpc"
        },
        {
          name  = "OTEL_RESOURCE_ATTRIBUTES"
          value = "service.name=workout"
        },
        {
          name  = "OTEL_PROPAGATORS"
          value = "tracecontext,baggage,xray"
        },
        {
          name  = "OTEL_LOGS_EXPORTER"
          value = "none"
        },
        {
          name  = "OTEL_TRACES_SAMPLER"
          value = "always_on"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_log_group.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    },
    {
      name      = "aws-otel-collector"
      image     = "public.ecr.aws/aws-observability/aws-otel-collector:latest"
      essential = true
      # command   = ["--config=/etc/ecs/ecs-default-config.yaml"]
      command   = ["--config=/etc/ecs/ecs-cloudwatch-xray.yaml"]
      
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_adot_log_group.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

# ECS service definition
resource "aws_ecs_service" "service" {
  count        = var.is_cost_saving ? 0 : 2

  name            = "${local.full_service_name}-env${count.index + 1}-service"
  cluster         = data.aws_ssm_parameter.ecs_cluster_id.value
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  health_check_grace_period_seconds = 180

  network_configuration {
    subnets          = data.aws_subnets.app_subnet.ids
    security_groups  = [data.aws_security_group.app_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.blue_tg[count.index].arn
     # Matches container name in task definition
    container_name   = "${local.full_service_name}-container"
    container_port   = 8092
  }

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  # Prevents TF from resetting desired_count back to 1 during deployments if auto-scaling has scaled it up
  lifecycle {
    ignore_changes = [
      task_definition, 
      load_balancer, 
      desired_count
    ]
  }
}

# Auto-scaling group and policy
resource "aws_appautoscaling_target" "ecs_target" {
  count        = var.is_cost_saving ? 0 : 2

  max_capacity       = 2
  min_capacity       = 0
  resource_id        = "service/${data.aws_ssm_parameter.ecs_cluster_name.value}/${aws_ecs_service.service[count.index].name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  count        = var.is_cost_saving ? 0 : 2

  name               = "cpu-tracking-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  service_namespace  = aws_appautoscaling_target.ecs_target[count.index].service_namespace
  resource_id        = aws_appautoscaling_target.ecs_target[count.index].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[count.index].scalable_dimension

  target_tracking_scaling_policy_configuration {
    target_value       = 70.0
    scale_in_cooldown  = 300
    scale_out_cooldown = 120

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}

resource "aws_appautoscaling_scheduled_action" "ecs_stop_service" {
  # No scheduled action in prod
  count        = !local.is_prod && var.is_cost_saving ? 0 : 2

  name               = "${local.full_service_name}-stop-ecs-service"
  service_namespace  = aws_appautoscaling_target.ecs_target[count.index].service_namespace
  resource_id        = aws_appautoscaling_target.ecs_target[count.index].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[count.index].scalable_dimension
  # 20:05 PM HK timezone
  schedule           = "cron(5 12 * * ? *)"

  scalable_target_action {
    min_capacity = 0
    max_capacity = 0
  }
}

resource "aws_appautoscaling_scheduled_action" "ecs_start_service" {
  # No scheduled action in prod
  count        = !local.is_prod && var.is_cost_saving ? 0 : 2

  name               = "${local.full_service_name}-start-ecs-service"
  service_namespace  = aws_appautoscaling_target.ecs_target[count.index].service_namespace
  resource_id        = aws_appautoscaling_target.ecs_target[count.index].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[count.index].scalable_dimension
  # 07:55 AM HK timezone
  schedule           = "cron(55 23 * * ? *)" 
  scalable_target_action {
    min_capacity = 1
    max_capacity = 2
  }
}

# Target Group - Blue
resource "aws_lb_target_group" "blue_tg" {
  count        = var.is_cost_saving ? 0 : 2

  name        = "${local.full_service_name}-env${count.index + 1}-blue"
  port        = 8092
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.main.id
  target_type = "ip"

  health_check {
    enabled             = true
    path                = "/planner/workout/health"
    protocol            = "HTTP"
    port                = "8092"
    interval            = 60
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 5
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Target Group - Green
resource "aws_lb_target_group" "green_tg" {
  count        = var.is_cost_saving ? 0 : 2

  name        = "${local.full_service_name}-env${count.index + 1}-green"
  port        = 8092
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.main.id
  target_type = "ip"

  health_check {
    enabled             = true
    path                = "/planner/workout/health"
    protocol            = "HTTP"
    port                = "8092"
    interval            = 60
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 5
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener_rule" "public_listener_rule" {
  count        = var.is_cost_saving ? 0 : 1
  
  listener_arn = data.aws_ssm_parameter.alb_listener_arn.value
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue_tg[0].arn
  }  

  condition {
    path_pattern {
      values = [
        "/planner/workout",
        "/planner/workout/*"
      ] 
    }
  }

  condition {
    http_header {
      http_header_name = "X-Origin-Verify"
      values           = [data.aws_ssm_parameter.cloudfront_origin_header.value]
    }
  }

  lifecycle {
    ignore_changes = [action[0].target_group_arn]
  }
}

resource "aws_lb_listener_rule" "pilot_listener_rule" {
  count        = var.is_cost_saving ? 0 : 1
  
  listener_arn = data.aws_ssm_parameter.alb_listener_arn.value
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue_tg[1].arn
  }
  
  condition {
    path_pattern {
      values = [
        "/planner/workout",
        "/planner/workout/*"
      ] 
    }
  }

  condition {
    http_header {
      http_header_name = "X-Origin-Verify"
      values           = [data.aws_ssm_parameter.cloudfront_origin_header.value]
    }
  }

  condition {
    http_header {
      http_header_name = "x-deployment-test"
      values           = ["true"]
    }
  }

  lifecycle {
    ignore_changes = [action[0].target_group_arn]
  }
}