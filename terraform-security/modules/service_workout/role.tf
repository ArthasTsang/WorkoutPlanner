resource "aws_iam_role" "service_team_role" {
  name = "${local.full_service_name}-${var.region}-terraform-role"

  assume_role_policy = jsonencode(
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "AllowServiceTeamToAssume",
          "Effect": "Allow",
          "Principal": {
            "AWS": [
              "arn:aws:iam::${local.account_id}:user/iamadmin",
              "arn:aws:iam::${local.account_id}:user/arthas"
            ]
          },
          "Action": "sts:AssumeRole"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "terraform_backend_policy_attachment" {
  role       = aws_iam_role.service_team_role.name
  policy_arn = aws_iam_policy.terraform_backend_policy.arn
}

resource "aws_iam_policy" "terraform_backend_policy" {
  name = "${local.full_service_name}-${var.region}-terraform-backend-policy"
  # role = aws_iam_role.service_team_role.id

  policy = jsonencode(
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "TerraformS3SearchPermission",
          "Effect": "Allow",
          "Action": [
            "s3:ListBucket"
          ],
          "Resource": [
            "arn:aws:s3:::twyat-${var.env}-${var.project}-terraform-${var.region}"
          ]
        },
        {
          "Sid": "TerraformS3Permission",
          "Effect": "Allow",
          "Action": [
            "s3:GetObject",
            "s3:PutObject",
            "s3:DeleteObject"
          ],
          "Resource": [
            "arn:aws:s3:::twyat-${var.env}-${var.project}-terraform-${var.region}/service/*"
          ]
        },
        {
          "Sid": "TerraformKMSPermission",
          "Effect": "Allow",
          "Action": [
            "kms:DescribeKey",
            "kms:Encrypt",
            "kms:Decrypt",
            "kms:GenerateDataKey"
          ],
          "Resource": "arn:aws:kms:${var.region}:${local.account_id}:key/*"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "terraform_iam_policy_attachment" {
  role       = aws_iam_role.service_team_role.name
  policy_arn = aws_iam_policy.terraform_iam_policy.arn
}

resource "aws_iam_policy" "terraform_iam_policy" {
  name = "${local.full_service_name}-${var.region}-terraform-iam-policy"
  # role = aws_iam_role.service_team_role.id

  policy = jsonencode(
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "EnforceRoleBoundary",
          "Effect": "Deny",
          "Action": [
            "iam:CreateRole",
            "iam:PutRolePermissionsBoundary"
          ],
          "Resource": "*",
          "Condition": {
            "StringNotEquals": {
              "iam:PermissionsBoundary": "arn:aws:iam::${local.account_id}:policy/${local.full_service_name}-${var.region}-scope-boundary-policy"
            }
          }
        },
        {
          "Sid": "DenyBoundaryModification",
          "Effect": "Deny",
          "Action": [
            "iam:DeleteRolePermissionsBoundary",
            "iam:CreatePolicyVersion",
            "iam:SetDefaultPolicyVersion",
            "iam:DeletePolicy",
            "iam:DeletePolicyVersion"
          ],
          "Resource": [
            "arn:aws:iam::${local.account_id}:policy/${local.full_service_name}-${var.region}-scope-boundary-policy"
          ]
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "terraform_ecs_policy_attachment" {
  role       = aws_iam_role.service_team_role.name
  policy_arn = aws_iam_policy.terraform_ecs_policy.arn
}

resource "aws_iam_policy" "terraform_ecs_policy" {
  name = "${local.full_service_name}-${var.region}-terraform-ecs-policy"
  # role = aws_iam_role.service_team_role.id

  policy = jsonencode(
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "TerraformIAMGlobalPermission",
          "Effect": "Allow",
          "Action": [
            "iam:ListAccountAliases"
          ],
          "Resource": "*"
        },
        {
          "Sid": "TerraformIAMPermission",
          "Effect": "Allow",
          "Action": [
            "iam:CreateRole",
            "iam:DeleteRole",
            "iam:GetRole",
            "iam:TagRole",
            "iam:PutRolePermissionsBoundary",
            "iam:GetRolePolicy",
            "iam:AttachRolePolicy",
            "iam:DetachRolePolicy",
            "iam:ListRolePolicies",
            "iam:ListAttachedRolePolicies",
            "iam:PutRolePolicy",
            "iam:DeleteRolePolicy",
            "iam:GetPolicy",
            "iam:GetPolicyVersion",
            "iam:ListInstanceProfilesForRole"
          ],
          "Resource": [
            "arn:aws:iam::${local.account_id}:role/mwp-*",
            "arn:aws:iam::${local.account_id}:policy/mwp-*",
            "arn:aws:iam::aws:policy/*"
          ]
        },
        {
          "Sid": "TerraformCreateServiceLinkedRoleForECSAutoScaling",
          "Effect": "Allow",
          "Action": "iam:CreateServiceLinkedRole",
          "Resource": "*",
          "Condition": {
            "StringEquals": {
              "iam:AWSServiceName": "ecs.application-autoscaling.amazonaws.com"
            }
          }
        },
        {
          "Sid": "TerraformPassRoleToECSTasks",
          "Effect": "Allow",
          "Action": [
            "iam:PassRole"
          ],
          "Resource": [
            "arn:aws:iam::${local.account_id}:role/mwp-*"
          ],
          "Condition": {
            "StringEquals": {
              "iam:PassedToService": [
                "ecs-tasks.amazonaws.com"
              ]
            }
          }
        },
        {
          "Sid": "TerraformECSGlobalPermission",
          "Effect": "Allow",
          "Action": [
            "ecs:DeregisterTaskDefinition",
            "ecs:DescribeTaskDefinition",
            "ecs:ListServices"
          ],
          "Resource": "*"
        },
        {
          "Sid": "TerraformECSPermission",
          "Effect": "Allow",
          "Action": [
            "ecs:RegisterTaskDefinition",
            "ecs:CreateService",
            "ecs:UpdateService",
            "ecs:DeleteService",
            "ecs:DescribeServices",
            "ecs:TagResource"
          ],
          "Resource": [
            "arn:aws:ecs:${var.region}:${local.account_id}:task-definition/*",
            "arn:aws:ecs:${var.region}:${local.account_id}:service/*"
          ],
          "Condition": {
            "StringEquals": {
              "aws:ResourceTag/Service": "workout"
            }
          }
        },
        {
          "Sid": "TerraformSSMParamterPermission",
          "Effect": "Allow",
          "Action": [
            "ssm:GetParameter",
            "ssm:GetParameters"
          ],
          "Resource": [
            "arn:aws:ssm:${var.region}:${local.account_id}:parameter/platform/*"
          ],
          "Condition": {
            "StringEquals": {
              "aws:ResourceTag/Project": "mwp"
            }
          }
        },
        {
          "Sid": "TerraformCloudWatchGlobalPermission",
          "Effect": "Allow",
          "Action": [
            "logs:DescribeLogGroups"
          ],
          "Resource": "*"
        },
        {
          "Sid": "TerraformCloudWatchPermission",
          "Effect": "Allow",
          "Action": [
            "logs:CreateLogGroup",
            "logs:DeleteLogGroup",
            "logs:ListTagsForResource",
            "logs:TagResource",
            "logs:PutRetentionPolicy"
          ],
          "Resource": [
            "arn:aws:logs:${var.region}:${local.account_id}:log-group:*"
          ],
          "Condition": {
            "StringEquals": {
              "aws:ResourceTag/Service": "workout"
            }
          }
        },
        {
          "Sid": "TerraformVPCGlobalPermission",
          "Effect": "Allow",
          "Action": [
            "ec2:DescribeVpcs",
            "ec2:DescribeVpcAttribute",
            "ec2:DescribeSubnets",
            "ec2:DescribeSecurityGroups"
          ],
          "Resource": "*"
        },
        {
          "Sid": "TerraformELBGlobalPermission",
          "Effect": "Allow",
          "Action": [
            "elasticloadbalancing:DescribeTargetGroups",
            "elasticloadbalancing:DescribeTargetGroupAttributes",
            "elasticloadbalancing:DescribeRules",
            "elasticloadbalancing:DescribeTags"
          ],
          "Resource": "*"
        },
        {
          "Sid": "TerraformELBPermission",
          "Effect": "Allow",
          "Action": [
            "elasticloadbalancing:CreateTargetGroup",
            "elasticloadbalancing:ModifyTargetGroup",
            "elasticloadbalancing:DeleteTargetGroup",
            "elasticloadbalancing:ModifyTargetGroupAttributes",
            "elasticloadbalancing:CreateRule",
            "elasticloadbalancing:ModifyRule",
            "elasticloadbalancing:DeleteRule",
            "elasticloadbalancing:AddTags",
            "elasticloadbalancing:RemoveTags"
          ],
          "Resource": [
            "arn:aws:elasticloadbalancing:${var.region}:${local.account_id}:targetgroup/*",
            "arn:aws:elasticloadbalancing:${var.region}:${local.account_id}:listener/app/*",
            "arn:aws:elasticloadbalancing:${var.region}:${local.account_id}:listener-rule/app/*"
          ],
          "Condition": {
            "StringEquals": {
              "aws:ResourceTag/Service": "workout"
            }
          }
        },
        {
          "Sid": "TerraformAutoScalingGlobalPermission",
          "Effect": "Allow",
          "Action": [
            "application-autoscaling:DescribeScalableTargets",
            "application-autoscaling:DescribeScalingPolicies",
            "application-autoscaling:DescribeScheduledActions"
          ],
          "Resource": "*"
        },
        {
          "Sid": "TerraformAutoScalingPermission",
          "Effect": "Allow",
          "Action": [
            "application-autoscaling:RegisterScalableTarget",
            "application-autoscaling:DeregisterScalableTarget",
            "application-autoscaling:PutScalingPolicy",
            "application-autoscaling:DeleteScalingPolicy",
            "application-autoscaling:PutScheduledAction",
            "application-autoscaling:DeleteScheduledAction",
            "application-autoscaling:TagResource",
            "application-autoscaling:ListTagsForResource"
          ],
          "Resource": [
            "arn:aws:application-autoscaling:${var.region}:${local.account_id}:scalable-target/*"
          ],
          "Condition": {
            "StringEquals": {
              "aws:ResourceTag/Service": "workout"
            }
          }
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "terraform_codedeploy_policy_attachment" {
  role       = aws_iam_role.service_team_role.name
  policy_arn = aws_iam_policy.terraform_codedeploy_policy.arn
}

resource "aws_iam_policy" "terraform_codedeploy_policy" {
  name = "${local.full_service_name}-${var.region}-terraform-codedeploy-policy"
  # role = aws_iam_role.service_team_role.id

  policy = jsonencode(
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "TerraformIAMGlobalPermission",
          "Effect": "Allow",
          "Action": [
            "iam:ListAccountAliases"
          ],
          "Resource": "*"
        },
        {
          "Sid": "TerraformIAMPermission",
          "Effect": "Allow",
          "Action": [
            "iam:CreateRole",
            "iam:DeleteRole",
            "iam:GetRole",
            "iam:TagRole",
            "iam:PutRolePermissionsBoundary",
            "iam:GetRolePolicy",
            "iam:AttachRolePolicy",
            "iam:DetachRolePolicy",
            "iam:ListRolePolicies",
            "iam:ListAttachedRolePolicies",
            "iam:PutRolePolicy",
            "iam:DeleteRolePolicy",
            "iam:GetPolicy",
            "iam:GetPolicyVersion"
          ],
          "Resource": [
            "arn:aws:iam::${local.account_id}:role/mwp-*",
            "arn:aws:iam::${local.account_id}:policy/mwp-*",
            "arn:aws:iam::aws:policy/*"
          ]
        },
        {
          "Sid": "TerraformPassRoleToCodeDeploy",
          "Effect": "Allow",
          "Action": "iam:PassRole",
          "Resource": "arn:aws:iam::${local.account_id}:role/mwp-*",
          "Condition": {
            "StringEquals": {
              "iam:PassedToService": "codedeploy.amazonaws.com"
            }
          }
        },
        {
          "Sid": "TerraformSSMParamterPermission",
          "Effect": "Allow",
          "Action": [
            "ssm:GetParameter",
            "ssm:GetParameters"
          ],
          "Resource": [
            "arn:aws:ssm:${var.region}:${local.account_id}:parameter/platform/*"
          ]
        },
        {
          "Sid": "ManageCodeDeployApplication",
          "Effect": "Allow",
          "Action": [
            "codedeploy:CreateApplication",
            "codedeploy:UpdateApplication",
            "codedeploy:DeleteApplication",
            "codedeploy:GetApplication",
            "codedeploy:CreateDeploymentGroup",
            "codedeploy:UpdateDeploymentGroup",
            "codedeploy:DeleteDeploymentGroup",
            "codedeploy:GetDeploymentGroup",
            "codedeploy:TagResource",
            "codedeploy:ListTagsForResource"
          ],
          "Resource": [
            "arn:aws:codedeploy:${var.region}:${local.account_id}:application:*",
            "arn:aws:codedeploy:${var.region}:${local.account_id}:deploymentgroup:*"
          ]
        }
      ]
    }
  )
}

resource "aws_iam_policy" "terraform_scope_boundary_policy" {
  name = "${local.full_service_name}-${var.region}-scope-boundary-policy"

  policy = jsonencode(
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "AllowIAMAction",
          "Effect": "Allow",
          "Action": [
            "iam:Get*",
            "iam:List*"
          ],
          "Resource": "*"
        },
        {
          "Sid": "AllowIAMPassRole",
          "Effect": "Allow",
          "Action": [
            "iam:PassRole"
          ],
          "Resource": "*",
          "Condition": {
            "StringLike": {
              "iam:PassedToService": [
                "ecs-tasks.amazonaws.com"
              ]
            }
          }
        },
        {
          "Sid": "AllowAWSServiceScope",
          "Effect": "Allow",
          "Action": [
            "kms:*",
            "ssm:*",
            "secretsmanager:*",	
            "s3:*",
            "elasticloadbalancing:*",
            "ecr:*",
            "ecs:*",
            "lambda:*",
            "rds-db:*",
            "sns:*",
            "cloudwatch:*",
            "logs:*",		
            "xray:*"
          ],
          "Resource": "*"
        },
        {
          "Sid": "DenyBoundaryModification",
          "Effect": "Deny",
          "Action": [
            "iam:DeleteRolePermissionsBoundary",
            "iam:CreatePolicyVersion",
            "iam:SetDefaultPolicyVersion",
            "iam:DeletePolicy",
            "iam:DeletePolicyVersion"
          ],
          "Resource": "arn:aws:iam::${local.account_id}:policy/${local.full_service_name}-${var.region}-scope-boundary-policy"
        },
        {
          "Sid": "DenySecurityInfrastructureAlteration",
          "Effect": "Deny",
          "Action": [
            "cloudtrail:DeleteTrail",
            "cloudtrail:StopLogging",
            "cloudtrail:UpdateTrail",
            "guardduty:DeleteDetector",
            "guardduty:DisassociateFromMasterAccount",
            "organizations:LeaveOrganization"
          ],
          "Resource": "*"
        },
        {
          "Sid": "RestrictDataExfiltration",
          "Effect": "Deny",
          "Action": [
            "s3:DeleteBucket",
            "s3:PutBucketPolicy"
          ],
          "Resource": [
            "arn:aws:s3:::twyat-log-*"
          ]
        }
      ]
    }
  )
}