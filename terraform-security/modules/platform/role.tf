resource "aws_iam_role" "platform_team_role" {
  name = "${local.name_prefix}-${var.region}-terraform-role"

  assume_role_policy = jsonencode(
    {
      "Version": "2012-10-17",
      "Statement": [
      {
        "Sid": "AllowPlatformTeamToAssume",
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
  role       = aws_iam_role.platform_team_role.name
  policy_arn = aws_iam_policy.terraform_backend_policy.arn
}

resource "aws_iam_policy" "terraform_backend_policy" {
  name = "${local.name_prefix}-${var.region}-terraform-backend-policy"
  # role = aws_iam_role.platform_team_role.id

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
            "arn:aws:s3:::twyat-${var.env}-${var.project}-terraform-${var.region}/platform/*"
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
  role       = aws_iam_role.platform_team_role.name
  policy_arn = aws_iam_policy.terraform_iam_policy.arn
}

resource "aws_iam_policy" "terraform_iam_policy" {
  name = "${local.name_prefix}-${var.region}-terraform-iam-policy"
  # role = aws_iam_role.platform_team_role.id

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
              "iam:PermissionsBoundary": "arn:aws:iam::${local.account_id}:policy/${var.project}-platform-${var.region}-scope-boundary-policy"
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
            "arn:aws:iam::${local.account_id}:policy/${var.project}-platform-${var.region}-scope-boundary-policy"
          ]
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "terraform_docdb_policy_attachment" {
  role       = aws_iam_role.platform_team_role.name
  policy_arn = aws_iam_policy.terraform_docdb_policy.arn
}

resource "aws_iam_policy" "terraform_docdb_policy" {
  name = "${local.name_prefix}-${var.region}-terraform-docdb-policy"
  # role = aws_iam_role.platform_team_role.id

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
            "iam:UpdateRole",
            "iam:DeleteRole",
            "iam:GetRole",
            "iam:TagRole",
            "iam:PutRolePermissionsBoundary",
            "iam:PutRolePolicy",
            "iam:GetRolePolicy",
            "iam:ListRolePolicies",
            "iam:ListAttachedRolePolicies",
            "iam:ListInstanceProfilesForRole",
            "iam:AttachRolePolicy",
            "iam:DetachRolePolicy",
            "iam:DeleteRolePolicy",
            "iam:CreatePolicy",
            "iam:GetPolicy",
            "iam:DeletePolicy",
            "iam:CreatePolicyVersion",
            "iam:DeletePolicyVersion",
            "iam:GetPolicyVersion",
            "iam:ListPolicyVersions",
            "iam:TagPolicy"
            ],
          "Resource": [
            "arn:aws:iam::${local.account_id}:role/mwp-*",
            "arn:aws:iam::${local.account_id}:policy/mwp-*"
          ]
        },
        {
          "Sid": "TerraformPassRoleToLambda",
          "Effect": "Allow",
          "Action": "iam:PassRole",
          "Resource": "arn:aws:iam::${local.account_id}:role/mwp-*",
          "Condition": {
            "StringEquals": {
              "iam:PassedToService": "lambda.amazonaws.com"
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
            "ec2:CreateNetworkInterface",
            "ec2:DeleteNetworkInterface",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DescribeSecurityGroups",
            "ec2:CreateSecurityGroup",
            "ec2:DeleteSecurityGroup",
            "ec2:AuthorizeSecurityGroupIngress",
            "ec2:AuthorizeSecurityGroupEgress",
            "ec2:RevokeSecurityGroupIngress",
            "ec2:RevokeSecurityGroupEgress",
            "ec2:DescribeSecurityGroupRules",
            "ec2:UpdateSecurityGroupRuleDescriptionsIngress",
            "ec2:UpdateSecurityGroupRuleDescriptionsEgress",
            "ec2:CreateTags"
          ],
          "Resource": "*"
        },
        {
          "Sid": "TerraformDatabaseGlobalPermission",
          "Effect": "Allow",
          "Action": [
            "rds:DescribeGlobalClusters"
          ],
          "Resource": "*"
        },
        {
          "Sid": "TerraformDatabasePermission",
          "Effect": "Allow",
          "Action": [
            "rds:CreateDBCluster",
            "rds:DeleteDBCluster",
            "rds:ModifyDBCluster",
            "rds:DescribeDBClusters",
            "rds:CreateDBSubnetGroup",
            "rds:ModifyDBSubnetGroup",
            "rds:DeleteDBSubnetGroup",
            "rds:DescribeDBSubnetGroups",
            "rds:CreateDBInstance",
            "rds:ModifyDBInstance",
            "rds:DeleteDBInstance",
            "rds:DescribeDBInstances",
            "rds:AddTagsToResource",
            "rds:ListTagsForResource",
            "rds:RestoreDBClusterFromSnapshot"
          ],
          "Resource": "arn:aws:rds:${var.region}:${local.account_id}:*"
        },
        {
          "Sid": "TerraformLambdaPermission",
          "Effect": "Allow",
          "Action": [
            "lambda:CreateFunction",
            "lambda:GetFunction",
            "lambda:DeleteFunction",
            "lambda:InvokeFunction",
            "lambda:UpdateFunctionCode",
            "lambda:UpdateFunctionConfiguration",
            "lambda:GetFunctionCodeSigningConfig",
            "lambda:PublishVersion",
            "lambda:ListVersionsByFunction",
            "lambda:CreateAlias",
            "lambda:GetAlias",
            "lambda:UpdateAlias",
            "lambda:DeleteAlias",
            "lambda:AddPermission",
            "lambda:RemovePermission",
            "lambda:GetPolicy",
            "lambda:TagResource"
          ],
          "Resource": "arn:aws:lambda:${var.region}:${local.account_id}:function:*"
        },
        {
          "Sid": "TerraformS3LambdaSourcePermission",
          "Effect": "Allow",
          "Action": [
            "s3:GetObject",
            "s3:GetObjectVersion",
            "s3:GetObjectTagging"
          ],
          "Resource": [
            "arn:aws:s3:::twyat-${var.env}-${var.project}-artifact-${var.region}/lambda/*",
          ]
        },
        {
          "Sid": "TerraformKMSGlobalPermissions",
          "Effect": "Allow",
          "Action": [
            "kms:ListAliases"
          ],
          "Resource": "*"
        },
        {
          "Sid": "TerraformKMSPermissions",
          "Effect": "Allow",
          "Action": [
            "kms:DescribeKey",
            "kms:Encrypt",
            "kms:Decrypt",
            "kms:GenerateDataKey"
          ],
          "Resource": "arn:aws:kms:${var.region}:${local.account_id}:key/*"
        },
        {
          "Sid": "TerraformSecretManagerPermission",
          "Effect": "Allow",
          "Action": [
            "secretsmanager:CreateSecret",
            "secretsmanager:UpdateSecret",
            "secretsmanager:DeleteSecret",
            "secretsmanager:DescribeSecret",
            "secretsmanager:RotateSecret",
            "secretsmanager:CancelRotateSecret",				
            "secretsmanager:UpdateSecretVersionStage",
            "secretsmanager:PutSecretValue",
            "secretsmanager:GetSecretValue",
            "secretsmanager:GetResourcePolicy",
            "secretsmanager:DeleteResourcePolicy",
            "secretsmanager:TagResource"
          ],
          "Resource": "arn:aws:secretsmanager:${var.region}:${local.account_id}:secret:/mwp/*"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "terraform_scheduler_policy_attachment" {
  role       = aws_iam_role.platform_team_role.name
  policy_arn = aws_iam_policy.terraform_scheduler_policy.arn
}

resource "aws_iam_policy" "terraform_scheduler_policy" {
  name = "${local.name_prefix}-${var.region}-terraform-scheduler-policy"
  # role = aws_iam_role.platform_team_role.id

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
            "iam:UpdateRole",
            "iam:DeleteRole",
            "iam:GetRole",
            "iam:TagRole",
            "iam:PutRolePermissionsBoundary",
            "iam:PutRolePolicy",
            "iam:GetRolePolicy",
            "iam:ListRolePolicies",
            "iam:ListAttachedRolePolicies",
            "iam:ListInstanceProfilesForRole",
            "iam:AttachRolePolicy",
            "iam:DetachRolePolicy",
            "iam:DeleteRolePolicy",	
            "iam:CreatePolicy",
            "iam:GetPolicy",
            "iam:DeletePolicy",
            "iam:CreatePolicyVersion",
            "iam:DeletePolicyVersion",
            "iam:GetPolicyVersion",
            "iam:ListPolicyVersions",
            "iam:TagPolicy"
            ],
          "Resource": [
            "arn:aws:iam::${local.account_id}:role/mwp-*",
            "arn:aws:iam::${local.account_id}:policy/mwp-*"
          ]
        },
        {
          "Sid": "TerraformPassRoleToEventBridge",
          "Effect": "Allow",
          "Action": "iam:PassRole",
          "Resource": "arn:aws:iam::${local.account_id}:role/mwp-*",
          "Condition": {
            "StringEquals": {
              "iam:PassedToService": "scheduler.amazonaws.com"
            }
          }
        },
        {
          "Sid": "TerraformEventBridgePermission",
          "Effect": "Allow",
          "Action": [
            "scheduler:CreateSchedule",
            "scheduler:DeleteSchedule",
            "scheduler:GetSchedule",
            "scheduler:UpdateSchedule"
          ],
          "Resource": "arn:aws:scheduler:${var.region}:${local.account_id}:*"
        },
        {
          "Sid": "TerraformSQSPermission",
          "Effect": "Allow",
          "Action": [
            "sqs:CreateQueue",
            "sqs:DeleteQueue",
            "sqs:GetQueueAttributes",
            "sqs:SetQueueAttributes",
            "sqs:listqueuetags",
            "sqs:tagqueue"
          ],
          "Resource": "arn:aws:sqs:${var.region}:${local.account_id}:*"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "terraform_app_policy_attachment" {
  role       = aws_iam_role.platform_team_role.name
  policy_arn = aws_iam_policy.terraform_app_policy.arn
}

resource "aws_iam_policy" "terraform_app_policy" {
  name = "${local.name_prefix}-${var.region}-terraform-app-policy"
  # role = aws_iam_role.platform_team_role.id

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
            "iam:UpdateRole",
            "iam:GetRole",
            "iam:PutRolePermissionsBoundary",
            "iam:PutRolePolicy",
            "iam:DeleteRolePolicy",
            "iam:GetRolePolicy",
            "iam:AttachRolePolicy",
            "iam:DetachRolePolicy",
            "iam:ListAttachedRolePolicies",
            "iam:ListRolePolicies",
            "iam:CreateInstanceProfile",
            "iam:DeleteInstanceProfile",
            "iam:GetInstanceProfile",
            "iam:AddRoleToInstanceProfile",
            "iam:RemoveRoleFromInstanceProfile",
            "iam:ListInstanceProfilesForRole",
            "iam:TagInstanceProfile"
          ],
          "Resource": [
            "arn:aws:iam::${local.account_id}:role/mwp-*",
            "arn:aws:iam::${local.account_id}:policy/mwp-*",
            "arn:aws:iam::${local.account_id}:instance-profile/mwp-*"
          ]
        },
        {
          "Sid": "TerraformEC2PassRolePermissions",
          "Effect": "Allow",
          "Action": "iam:PassRole",
          "Resource": "arn:aws:iam::${local.account_id}:role/mwp-*",
          "Condition": {
            "StringEquals": {
              "iam:PassedToService": "ec2.amazonaws.com"
            }
          }
        },
        {
          "Sid": "TerraformVPCCPermission",
          "Effect": "Allow",
          "Action": [
            "ec2:DescribeVpcs",
            "ec2:DescribeSubnets",
            "ec2:DescribeSecurityGroups",
            "ec2:DescribeInternetGateways",
            "ec2:DescribeAccountAttributes"
          ],
          "Resource": "*"
        },
        {
          "Sid": "TerraformELBGlobalPermission",
          "Effect": "Allow",
          "Action": [
            "elasticloadbalancing:DescribeLoadBalancers",
            "elasticloadbalancing:DescribeLoadBalancerAttributes",
            "elasticloadbalancing:DescribeListeners",
            "elasticloadbalancing:DescribeListenerAttributes", 
            "elasticloadbalancing:DescribeTags"
          ],
          "Resource": "*"
        },
        {
          "Sid": "TerraformELBPermission",
          "Effect": "Allow",
          "Action": [
            "elasticloadbalancing:CreateLoadBalancer",
            "elasticloadbalancing:DeleteLoadBalancer",
            "elasticloadbalancing:ModifyLoadBalancerAttributes",
            "elasticloadbalancing:CreateListener",
            "elasticloadbalancing:ModifyListener",
            "elasticloadbalancing:DeleteListener",
            "elasticloadbalancing:AddTags",
            "elasticloadbalancing:RemoveTags"
          ],
          "Resource": [
            "arn:aws:elasticloadbalancing:${var.region}:${local.account_id}:loadbalancer/*",
            "arn:aws:elasticloadbalancing:${var.region}:${local.account_id}:listener/*"
          ]
        },
        {
          "Sid": "TerraformECSClusterPermissions",
          "Effect": "Allow",
          "Action": [
            "ecs:CreateCluster",
            "ecs:DeleteCluster",
            "ecs:DescribeClusters",
            "ecs:UpdateCluster",
            "ecs:ListTagsForResource",
            "ecs:TagResource",
            "ecs:UntagResource"
          ],
          "Resource": [
            "arn:aws:ecs:${var.region}:${local.account_id}:cluster/*"
          ]
        },
        {
          "Sid": "TerraformSSMParameterGlobalPermissions",
          "Effect": "Allow",
          "Action": [
            "ssm:DescribeParameters"
          ],
          "Resource": "*"
        },
        {
          "Sid": "TerraformSSMParameterPermissions",
          "Effect": "Allow",
          "Action": [
            "ssm:PutParameter",
            "ssm:DeleteParameter",
            "ssm:GetParameter",
            "ssm:GetParameters",
            "ssm:AddTagsToResource",
            "ssm:RemoveTagsFromResource",
            "ssm:ListTagsForResource"
          ],
          "Resource": [
            "arn:aws:ssm:${var.region}:${local.account_id}:parameter/platform/services/*"
            # "arn:aws:ssm:${var.region}:${local.account_id}:parameter/platform/mwp/*"
          ]
        },
        {
          "Sid": "TerraformEC2LaunchTemplateGlobalPermissions",
          "Effect": "Allow",
          "Action": [
            "ec2:DescribeImages",
            "ec2:DescribeLaunchTemplates",
            "ec2:DescribeLaunchTemplateVersions"
          ],
          "Resource": "*"
        },
        {
          "Sid": "TerraformEC2LaunchTemplatePermissions",
          "Effect": "Allow",
          "Action": [
            "ec2:CreateLaunchTemplate",
            "ec2:DeleteLaunchTemplate",				   
            "ec2:CreateLaunchTemplateVersion",
            "ec2:DeleteLaunchTemplateVersions",
            "ec2:ModifyLaunchTemplate"
          ],
          "Resource": [
            "arn:aws:ec2:${var.region}:${local.account_id}:launch-template/*"
          ]
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "terraform_edge_policy_attachment" {
  role       = aws_iam_role.platform_team_role.name
  policy_arn = aws_iam_policy.terraform_edge_policy.arn
}

resource "aws_iam_policy" "terraform_edge_policy" {
  name = "${local.name_prefix}-${var.region}-terraform-edge-policy"
  # role = aws_iam_role.platform_team_role.id

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
          "Sid": "TerraformIAMRoleForLambdaEdgePermission",
          "Effect": "Allow",
          "Action": [
            "iam:CreateRole",
            "iam:DeleteRole",
            "iam:GetRole",
            "iam:UpdateRole",
            "iam:AttachRolePolicy",
            "iam:DetachRolePolicy",
            "iam:ListAttachedRolePolicies"
          ],
          "Resource": "arn:aws:iam::${local.account_id}:role/mwp-lambda-*-role"
        },
        {
          "Sid": "TerraformPassRoleForLambdaPermission",
          "Effect": "Allow",
          "Action": "iam:PassRole",
          "Resource": "arn:aws:iam::${local.account_id}:role/mwp-lambda-*-role",
          "Condition": {
            "StringEquals": {
              "iam:PassedToService": [
                "lambda.amazonaws.com",
                "edgelambda.amazonaws.com"
              ]
            }
          }
        },
        {
          "Sid": "TerraformCreateServiceLinkedRoleForLambdaPermission",
          "Effect": "Allow",
          "Action": "iam:CreateServiceLinkedRole",
          "Resource": "*",
          "Condition": {
            "StringEquals": {
              "iam:AWSServiceName": "replicator.lambda.amazonaws.com"
            }
          }
        },
        {
          "Sid": "TerraformCloudFrontGlobalPermission",
          "Effect": "Allow",
          "Action": [
            "cloudfront:CreateDistribution",
            "cloudfront:CreateOriginAccessControl",
            "cloudfront:CreateOriginRequestPolicy",
            "cloudfront:ListCachePolicies",
            "cloudfront:CreateFunction"
          ],
          "Resource": "*"
        },
        {
          "Sid": "TerraformCloudFrontPermission",
          "Effect": "Allow",
          "Action": [
            "cloudfront:UpdateDistribution",
            "cloudfront:DeleteDistribution",
            "cloudfront:GetDistribution",
            "cloudfront:UpdateOriginAccessControl",
            "cloudfront:DeleteOriginAccessControl",
            "cloudfront:GetOriginAccessControl",
            "cloudfront:UpdateOriginRequestPolicy",
            "cloudfront:DeleteOriginRequestPolicy",
            "cloudfront:GetOriginRequestPolicy",
            "cloudfront:GetCachePolicy",
            "cloudfront:UpdateFunction",
            "cloudfront:DeleteFunction",
            "cloudfront:GetFunction",
            "cloudfront:PublishFunction",
            "cloudfront:DescribeFunction",
            "cloudfront:TagResource",
            "cloudfront:ListTagsForResource"
          ],
          "Resource": [
            "arn:aws:cloudfront::${local.account_id}:distribution/*",
            "arn:aws:cloudfront::${local.account_id}:origin-access-control/*",
            "arn:aws:cloudfront::${local.account_id}:origin-request-policy/*",
            "arn:aws:cloudfront::${local.account_id}:cache-policy/*",
            "arn:aws:cloudfront::${local.account_id}:function/*",
            "arn:aws:cloudfront::${local.account_id}:vpcorigin/*"
          ]
        },
        {
          "Sid": "TerraformS3OriginPermission",
          "Effect": "Allow",
          "Action": [
            "s3:CreateBucket",
            "s3:DeleteBucket",
            "s3:ListBucket",
            "s3:GetBucketLocation",
            "s3:PutBucketAcl",
            "s3:GetBucketAcl",
            "s3:PutBucketCORS",
            "s3:GetBucketCORS",
            "s3:PutBucketWebsite",
            "s3:DeleteBucketWebsite",
            "s3:GetBucketWebsite",
            "s3:PutBucketVersioning",
            "s3:GetBucketVersioning",
            "s3:PutBucketRequestPayment",
            "s3:GetBucketRequestPayment",
            "s3:PutBucketLogging",
            "s3:GetBucketLogging",
            "s3:PutLifecycleConfiguration",
            "s3:GetLifecycleConfiguration",
            "s3:PutReplicationConfiguration",
            "s3:GetReplicationConfiguration",
            "s3:PutEncryptionConfiguration",
            "s3:GetEncryptionConfiguration",
            "s3:PutBucketObjectLockConfiguration",
            "s3:GetBucketObjectLockConfiguration",
            "s3:PutBucketPublicAccessBlock",
            "s3:GetBucketPublicAccessBlock",
            "s3:PutBucketTagging",
            "s3:GetBucketTagging",
            "s3:PutBucketPolicy",
            "s3:DeleteBucketPolicy",
            "s3:GetBucketPolicy"
          ],
          "Resource": [
            "arn:aws:s3:::twyat-${var.env}-${var.project}-frontend-${var.region}"
          ]
        },
        {
          "Sid": "KMSDecryptS3OriginPermissions",
          "Effect": "Allow",
          "Action": [
            "kms:Decrypt"
          ],
          "Resource": "arn:aws:kms:${var.region}:${local.account_id}:key/*"
        },
        {
          "Sid": "TerraformLambdaEdgePermission",
          "Effect": "Allow",
          "Action": [
            "lambda:CreateFunction",
            "lambda:DeleteFunction",
            "lambda:GetFunction",
            "lambda:InvokeFunction",
            "lambda:GetFunctionConfiguration",
            "lambda:UpdateFunctionCode",
            "lambda:UpdateFunctionConfiguration",
            "lambda:GetFunctionCodeSigningConfig",
            "lambda:PublishVersion",
            "lambda:ListVersionsByFunction",
            "lambda:CreateAlias",
            "lambda:GetAlias",
            "lambda:UpdateAlias",
            "lambda:DeleteAlias",
            "lambda:AddPermission",
            "lambda:RemovePermission",
            "lambda:GetPolicy",
            "lambda:TagResource",
            "lambda:EnableReplication",
            "lambda:DisableReplication"
          ],
          "Resource": "arn:aws:lambda:us-east-1:${local.account_id}:function:*"
        }, 
        {
          "Sid": "TerraformS3LambdaEdgeSourcePermission",
          "Effect": "Allow",
          "Action": [
            "s3:GetObject",
            "s3:GetObjectVersion",
            "s3:GetObjectTagging"
          ],
          "Resource": "arn:aws:s3:::twyat-${var.env}-${var.project}-artifact-us-east-1/lambda/*"
        },
        {
          "Sid": "KMSDecryptS3LambdaEdgeSourcePermissions",
          "Effect": "Allow",
          "Action": [
            "kms:Decrypt"
          ],
          "Resource": "arn:aws:kms:us-east-1:${local.account_id}:key/*"
        }		 
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "terraform_cognito_policy_attachment" {
  role       = aws_iam_role.platform_team_role.name
  policy_arn = aws_iam_policy.terraform_cognito_policy.arn
}

resource "aws_iam_policy" "terraform_cognito_policy" {
  name = "${local.name_prefix}-${var.region}-terraform-cognito-policy"
  # role = aws_iam_role.platform_team_role.id

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
          "Sid": "TerraformSecretsManagerPermission",
          "Effect": "Allow",
          "Action": [
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret"
          ],
          "Resource": "arn:aws:secretsmanager:${var.region}:${local.account_id}:secret:/mwp/*"
        },
        {
          "Sid": "TerraformCognitoGlobalPermission",
          "Effect": "Allow",
          "Action": [
            "cognito-idp:CreateUserPool",
            "cognito-idp:DescribeUserPoolDomain"
          ],
          "Resource": "*"
        },
        {
          "Sid": "TerraformCognitoPermission",
          "Effect": "Allow",
          "Action": [
            "cognito-idp:UpdateUserPool",
            "cognito-idp:DeleteUserPool",
            "cognito-idp:DescribeUserPool",
            "cognito-idp:CreateUserPoolDomain",
            "cognito-idp:DeleteUserPoolDomain",
            "cognito-idp:CreateIdentityProvider",
            "cognito-idp:UpdateIdentityProvider",
            "cognito-idp:DeleteIdentityProvider",
            "cognito-idp:DescribeIdentityProvider",
            "cognito-idp:CreateUserPoolClient",
            "cognito-idp:UpdateUserPoolClient",
            "cognito-idp:DeleteUserPoolClient",
            "cognito-idp:DescribeUserPoolClient",
            "cognito-idp:GetUserPoolMfaConfig",
            "cognito-idp:TagResource",
            "cognito-idp:UntagResource"
          ],
          "Resource": [
            "arn:aws:cognito-idp:${var.region}:${local.account_id}:userpool/*"
          ]
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "terraform_logging_policy_attachment" {
  role       = aws_iam_role.platform_team_role.name
  policy_arn = aws_iam_policy.terraform_logging_policy.arn
}

resource "aws_iam_policy" "terraform_logging_policy" {
  name = "${local.name_prefix}-${var.region}-terraform-logging-policy"
  # role = aws_iam_role.platform_team_role.id

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
          "Sid": "TerraformCloudWatchGlobalPermission",
          "Effect": "Allow",
          "Action": [
            "logs:PutAccountPolicy",
            "logs:DeleteAccountPolicy",
            "logs:DescribeAccountPolicies",
            "logs:DescribeLogGroups",
            "logs:ListTagsForResource"
          ],
          "Resource": "*"
        },
        {
          "Sid": "TerraformCloudWatchPermission",
          "Effect": "Allow",
          "Action": [
            "logs:PutRetentionPolicy",
            "logs:PutSubscriptionFilter",
            "logs:DeleteSubscriptionFilter",
            "logs:DescribeSubscriptionFilters",
            "logs:DescribeLogStreams",
            "logs:TagResource"
          ],
          "Resource": [
            "arn:aws:logs:${var.region}:${local.account_id}:*:*"
          ]
        },
        {
          "Sid": "TerraformSSMParameterGlobalPermission",
          "Effect": "Allow",
          "Action": [
            "ssm:DescribeParameters"
          ],
          "Resource": "*"
        },
        {
          "Sid": "TerraformSSMParameterPermission",
          "Effect": "Allow",
          "Action": [
            "ssm:PutParameter",
            "ssm:DeleteParameter",
            "ssm:GetParameter",
            "ssm:GetParameters",
            "ssm:AddTagsToResource",
            "ssm:RemoveTagsFromResource",
            "ssm:ListTagsForResource"
          ],
          "Resource": [
            "arn:aws:ssm:${var.region}:${var.log_account_id}:parameter/${var.project}/logging/${var.env}/*"
          ]
        }
      ]
    }
  )
}

resource "aws_iam_policy" "terraform_scope_boundary_policy" {
  name = "${local.name_prefix}-${var.region}-scope-boundary-policy"

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
          "Sid": "AllowAWSServiceScope",
          "Effect": "Allow",
          "Action": [
            "kms:*",
            "ssm:*",
            "ssmmessages:*",
            "secretsmanager:*",
            "s3:*",
            "ec2:*",
            "ec2messages:*",
            "lambda:*",
            "rds:*",
            "rds-db:*",
            "sqs:*",
            "logs:*"	
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
          "Resource": "arn:aws:iam::${local.account_id}:policy/${var.project}-platform-${var.region}-scope-boundary-policy"
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