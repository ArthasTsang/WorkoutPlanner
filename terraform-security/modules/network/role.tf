resource "aws_iam_role" "platform_team_role" {
  name = "${local.name_prefix}-${var.region}-terraform-role"

  assume_role_policy = jsonencode(
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "AllowNetworkTerraformGroupToAssume",
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
            "arn:aws:s3:::twyat-network-${var.project}-terraform-${var.region}"
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
            "arn:aws:s3:::twyat-network-${var.project}-terraform-${var.region}/network/*"
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

resource "aws_iam_role_policy_attachment" "terraform_vpc_policy_attachment" {
  role       = aws_iam_role.platform_team_role.name
  policy_arn = aws_iam_policy.terraform_vpc_policy.arn
}

resource "aws_iam_policy" "terraform_vpc_policy" {
  name = "${local.name_prefix}-${var.region}-terraform-vpc-policy"
  # role = aws_iam_role.platform_team_role.id

  policy = jsonencode(
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "TerraformVPCGlobalPermission",
          "Effect": "Allow",
          "Action": [
            "ec2:DescribeVpcs",
            "ec2:DescribeAvailabilityZones",
            "ec2:DescribeSubnets",
            "ec2:DescribeRouteTables",
            "ec2:DescribeInternetGateways",
            "ec2:DescribeAddresses",
            "ec2:DescribeAddressesAttribute",
            "ec2:DisassociateAddress",
            "ec2:DescribeNatGateways",
            "ec2:DescribeSecurityGroups",
            "ec2:DescribeSecurityGroupRules",
            "ec2:DescribeVpcEndpoints",
            "ec2:DescribeVpcEndpointServices",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DescribePrefixLists"
          ],
          "Resource": "*"
        },
        {
          "Sid": "TerraformVPCPermission",
          "Effect": "Allow",
          "Action": [
            "ec2:CreateVpc",
            "ec2:DeleteVpc",
            "ec2:ModifyVpcAttribute",
            "ec2:DescribeVpcAttribute",
            "ec2:CreateSubnet",
            "ec2:DeleteSubnet",
            "ec2:ModifySubnetAttribute",
            "ec2:CreateRouteTable",
            "ec2:DeleteRouteTable",
            "ec2:AssociateRouteTable",
            "ec2:DisassociateRouteTable",
            "ec2:CreateRoute",
            "ec2:DeleteRoute",
            "ec2:ReplaceRoute",
            "ec2:CreateInternetGateway",
            "ec2:DeleteInternetGateway",
            "ec2:AttachInternetGateway",
            "ec2:DetachInternetGateway",
            "ec2:CreateTags",
            "ec2:DeleteTags"
          ],
          "Resource": [
            "arn:aws:ec2:${var.region}:${local.account_id}:vpc/*",
            "arn:aws:ec2:${var.region}:${local.account_id}:subnet/*",
            "arn:aws:ec2:${var.region}:${local.account_id}:route-table/*",
            "arn:aws:ec2:${var.region}:${local.account_id}:internet-gateway/*"
          ]
        },
        {
          "Sid": "TerraformNATPermission",
          "Effect": "Allow",
          "Action": [
            "ec2:AllocateAddress",
            "ec2:ReleaseAddress",
            "ec2:CreateNatGateway",
            "ec2:DeleteNatGateway",
            "ec2:CreateTags",
            "ec2:DeleteTags"
          ],
          "Resource": [
            "arn:aws:ec2:${var.region}:${local.account_id}:vpc/*",
            "arn:aws:ec2:${var.region}:${local.account_id}:subnet/*",
            "arn:aws:ec2:${var.region}:${local.account_id}:natgateway/*",
            "arn:aws:ec2:${var.region}:${local.account_id}:elastic-ip/*",
            "arn:aws:ec2:${var.region}:${local.account_id}:network-interface/*"
          ]
        },
        {
          "Sid": "TerraformSecurityGroupPermission",
          "Effect": "Allow",
          "Action": [
            "ec2:CreateSecurityGroup",
            "ec2:DeleteSecurityGroup",
            "ec2:AuthorizeSecurityGroupIngress",
            "ec2:AuthorizeSecurityGroupEgress",
            "ec2:RevokeSecurityGroupIngress",
            "ec2:RevokeSecurityGroupEgress",
            "ec2:UpdateSecurityGroupRuleDescriptionsIngress",
            "ec2:UpdateSecurityGroupRuleDescriptionsEgress",
            "ec2:CreateTags",
            "ec2:DeleteTags"
          ],
          "Resource": [
            "arn:aws:ec2:${var.region}:${local.account_id}:vpc/*",
            "arn:aws:ec2:${var.region}:${local.account_id}:security-group/*",
            "arn:aws:ec2:${var.region}:${local.account_id}:security-group-rule/*"
          ]
        },
        {
          "Sid": "TerraformVPCEndpointPermission",
          "Effect": "Allow",
          "Action": [
            "ec2:CreateVpcEndpoint",
            "ec2:ModifyVpcEndpoint",
            "ec2:DeleteVpcEndpoints",
            "ec2:CreateNetworkInterface",
            "ec2:ModifyNetworkInterfaceAttribute",
            "ec2:DeleteNetworkInterface",
            "ec2:CreateTags",
            "ec2:DeleteTags"
          ],
          "Resource": [
            "arn:aws:ec2:${var.region}:${local.account_id}:vpc/*",
            "arn:aws:ec2:${var.region}:${local.account_id}:subnet/*",
            "arn:aws:ec2:${var.region}:${local.account_id}:vpc-endpoint/*",
            "arn:aws:ec2:${var.region}:${local.account_id}:network-interface/*",
            "arn:aws:ec2:${var.region}:${local.account_id}:route-table/*",
            "arn:aws:ec2:${var.region}:${local.account_id}:security-group/*"
          ]
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "terraform_ram_policy_attachment" {
  role       = aws_iam_role.platform_team_role.name
  policy_arn = aws_iam_policy.terraform_ram_policy.arn
}

resource "aws_iam_policy" "terraform_ram_policy" {
  name = "${local.name_prefix}-${var.region}-terraform-ram-policy"
  # role = aws_iam_role.platform_team_role.id

  policy = jsonencode(
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "TerraformVPCResourcePolicyPermission",
          "Effect": "Allow",
          "Action": [
            "ec2:PutResourcePolicy",
            "ec2:DeleteResourcePolicy"
          ],
          "Resource": "*"
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