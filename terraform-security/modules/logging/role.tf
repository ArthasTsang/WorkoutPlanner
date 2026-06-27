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
            "arn:aws:s3:::twyat-log-${var.project}-terraform-${var.region}"
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
            "arn:aws:s3:::twyat-log-${var.project}-terraform-${var.region}/platform/*"
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
          "Resource": [
            "arn:aws:kms:${var.region}:${local.account_id}:key/*"
          ]
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
              "iam:PermissionsBoundary": "arn:aws:iam::${local.account_id}:policy/${local.name_prefix}-${var.region}-scope-boundary-policy"
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
            "arn:aws:iam::${local.account_id}:policy/${local.name_prefix}-${var.region}-scope-boundary-policy"
          ]
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "terraform_firehose_policy_attachment" {
  role       = aws_iam_role.platform_team_role.name
  policy_arn = aws_iam_policy.terraform_firehose_policy.arn
}

resource "aws_iam_policy" "terraform_firehose_policy" {
  name = "${local.name_prefix}-${var.region}-terraform-firehose-policy"
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
          "Sid": "TerraformPassRoleToCloudWatch",
          "Effect": "Allow",
          "Action": "iam:PassRole",
          "Resource": "arn:aws:iam::${local.account_id}:role/mwp-*",
          "Condition": {
            "StringEquals": {
              "iam:PassedToService": "logs.amazonaws.com"
            }
          }
        },
        {
          "Sid": "TerraformPassRoleToFirehoseWatch",
          "Effect": "Allow",
          "Action": "iam:PassRole",
          "Resource": "arn:aws:iam::${local.account_id}:role/mwp-*",
          "Condition": {
            "StringEquals": {
              "iam:PassedToService": "firehose.amazonaws.com"
            }
          }
        },
        {
          "Sid": "TerraformCloudWatchGlobalPermission",
          "Effect": "Allow",
          "Action": [
            "logs:DescribeDestinations"
          ],
          "Resource": "*"
        },
        {
          "Sid": "TerraformCloudWatchPermission",
          "Effect": "Allow",
          "Action": [
            "logs:PutDestination",
            "logs:DeleteDestination",
            "logs:PutDestinationPolicy",
            "logs:PutDeliveryDestinationPolicy",
            "logs:DeleteDeliveryDestinationPolicy",
            "logs:GetDeliveryDestinationPolicy",
            "logs:ListTagsForResource",
            "logs:TagResource"
          ],
          "Resource": [
            "arn:aws:logs:${var.region}:${local.account_id}:destination:*"
          ]
        },
        {
          "Sid": "TerraformFirehosePermission",
          "Effect": "Allow",
          "Action": [
            "firehose:CreateDeliveryStream",
            "firehose:DeleteDeliveryStream",
            "firehose:DescribeDeliveryStream",
            "firehose:ListDeliveryStreams",
            "firehose:UpdateDestination",
            "firehose:ListTagsForDeliveryStream",
            "firehose:TagDeliveryStream"
          ],
          "Resource": [
            "arn:aws:firehose:${var.region}:${local.account_id}:deliverystream/*"
          ]
        },
        {
          "Sid": "TerraformS3Permission",
          "Effect": "Allow",
          "Action": [
            "s3:ListBucket",
            "s3:GetBucketLocation"
          ],
          "Resource": "arn:aws:s3:::twyat-log-${var.project}-${var.env}-log-archive-${var.region}"
        },
        {
          "Sid": "TerraformKMSGlobalPermission",
          "Effect": "Allow",
          "Action": [
            "kms:ListAliases"
          ],
          "Resource": "*"
        },
        {
          "Sid": "TerraformKMSPermission",
          "Effect": "Allow",
          "Action": [
            "kms:DescribeKey",
            "kms:GetKeyPolicy",
            "kms:PutKeyPolicy"
          ],
          "Resource": "arn:aws:kms:${var.region}:${local.account_id}:key/*"
        },
        {
          "Sid": "TerraformSSMParameterGlobalPermissions",
          "Effect": "Allow",
          "Action": [
            "ssm:DescribeParameters",
            "ssm:ListAssociations"
          ],
          "Resource": "*"
        },
        {
          "Sid": "TerraformSSMParameterPermissions",
          "Effect": "Allow",
          "Action": "*",
          "Resource": [
            "arn:aws:ssm:${var.region}:${local.account_id}:parameter/${var.project}/logging/*"
          ]
        },
        {
          "Sid": "TerraformRAMGlobalPermission",
          "Effect": "Allow",
          "Action": [
            "ram:CreateResourceShare",
            "ram:GetResourceShares",
            "ram:GetResourceShareAssociations",
            "ram:ListPrincipals",
            "ram:ListResources"
          ],
          "Resource": "*"
        },
        {
          "Sid": "TerraformRAMPermission",
          "Effect": "Allow",
          "Action": [
            "ram:UpdateResourceShare",
            "ram:DeleteResourceShare",
            "ram:AssociateResourceShare",
            "ram:DisassociateResourceShare",
            "ram:GetPermission",
            "ram:ListResourceSharePermissions",
            "ram:TagResource"
          ],
          "Resource": [
            "arn:aws:ram:${var.region}:${local.account_id}:resource-share/*",
            "arn:aws:ram:${var.region}:${local.account_id}:permission/*",
            "arn:aws:ram:${var.region}:${local.account_id}:customer-managed-permission/*"
          ]
        }
      ]
    }
  )
}

resource "aws_iam_policy" "terraform_scope_boundary_policy" {
  name = "${local.name_prefix}-${var.region}-scope-boundary-policy"
  # role = aws_iam_role.platform_team_role.id

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
            "s3:*",
            "logs:*",
            "firehose:*"
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
          "Resource": "arn:aws:iam::${local.account_id}:policy/${local.name_prefix}-${var.region}-scope-boundary-policy"
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