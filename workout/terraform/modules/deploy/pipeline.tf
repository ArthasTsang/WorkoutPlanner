data "aws_ssm_parameter" "alb_listener_arn" {
  name = "/platform/services/alb_listener_arn"
}

data "aws_ssm_parameter" "ecs_cluster_id" {
  name = "/platform/services/ec_cluster_id"
}

data "aws_ssm_parameter" "ecs_cluster_name" {
  name = "/platform/services/ec_cluster_name"
}

data "aws_iam_policy" "codedeploy_ecs" {
  arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}

# Service role
resource "aws_iam_role" "cd_service_role" {
  name = "${local.full_service_name}-codedeploy-role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": "codedeploy.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
            "Condition": {
              "StringEquals": {
                  "aws:SourceAccount": "${local.account_id}"
              }
          }
        }
    ]
  })

  permissions_boundary = "arn:aws:iam::${local.account_id}:policy/${local.full_service_name}-scope-boundary-policy"
}

resource "aws_iam_role_policy_attachment" "codedeploy_ecs_policy" {
  role       = aws_iam_role.cd_service_role.name
  policy_arn = data.aws_iam_policy.codedeploy_ecs.arn
}

# CodeDeploy Application
resource "aws_codedeploy_app" "ecs_app" {
  compute_platform = "ECS"
  name             = "${local.full_service_name}-app"
}

# # CodeDeploy Deployment Group
# resource "aws_codedeploy_deployment_group" "ecs_dg" {
#   count        = var.is_cost_saving ? 0 : 1
  
#   app_name               = aws_codedeploy_app.ecs_app.name
#   deployment_group_name  = "${local.full_service_name}-dg"
#   service_role_arn       = aws_iam_role.cd_service_role.arn
#   deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"

#   ecs_service {
#     cluster_name = data.aws_ssm_parameter.ecs_cluster_name.value
#     service_name = var.ecs_service_name[0]
#   }

#   deployment_style {
#     deployment_option = "WITH_TRAFFIC_CONTROL"
#     deployment_type   = "BLUE_GREEN"
#   }

#   # Configure Load Balancer Blue/Green settings
#   load_balancer_info {
#     target_group_pair_info {
#       # The production listener managing live user traffic
#       prod_traffic_route {
#         listener_arns = [data.aws_ssm_parameter.alb_listener_arn.value]
#       }

#       # Traffic Target Group 1 (Blue)
#       target_group {
#         name = var.blue_tg_name
#       }

#       # Traffic Target Group 2 (Green)
#       target_group {
#         name = var.green_tg_name
#       }
#     }
#   }

#   # Blue/Green Deployment Management Behavior
#   blue_green_deployment_config {
#     deployment_ready_option {
#       action_on_timeout = "CONTINUE_DEPLOYMENT" # Automatically routes traffic when ready
#     }

#     terminate_blue_instances_on_deployment_success {
#       action                           = "TERMINATE"
#       termination_wait_time_in_minutes = 5
#     }
#   }

#   # Optional: Automatically roll back if the deployment encounters errors
#   auto_rollback_configuration {
#     enabled = true
#     events  = ["DEPLOYMENT_FAILURE"]
#   }
# }

# CodeDeploy Deployment Group
resource "aws_codedeploy_deployment_group" "ecs_dg" {
  count        = var.is_cost_saving ? 0 : 2
  
  app_name               = aws_codedeploy_app.ecs_app.name
  deployment_group_name  = "${local.full_service_name}-env${count.index + 1}-dg"
  service_role_arn       = aws_iam_role.cd_service_role.arn
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"

  ecs_service {
    cluster_name = data.aws_ssm_parameter.ecs_cluster_name.value
    service_name = var.ecs_service_name[count.index]
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  # Configure Load Balancer Blue/Green settings
  load_balancer_info {
    target_group_pair_info {
      # The production listener managing live user traffic
      prod_traffic_route {
        listener_arns = [data.aws_ssm_parameter.alb_listener_arn.value]
      }

      # Traffic Target Group 1 (Blue)
      target_group {
        name = var.blue_tg_name[count.index]
      }

      # Traffic Target Group 2 (Green)
      target_group {
        name = var.green_tg_name[count.index]
      }
    }
  }

  # Blue/Green Deployment Management Behavior
  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT" # Automatically routes traffic when ready
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  # Optional: Automatically roll back if the deployment encounters errors
  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
}