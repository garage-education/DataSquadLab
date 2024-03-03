################################################################################
# GitHub OIDC Provider
# Note: This is one per AWS account
################################################################################
module "iam_github_oidc_provider" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-github-oidc-provider"
  version = "5.34.0"
  tags = merge(local.default_tags, {
    yor_name = "iam_github_oidc_provider"
    Name     = "${local.name_prefix}-action-oidc-provider"
    }
  )
}
#################################################################################
## GitHub OIDC Role
#################################################################################
module "iam_github_oidc_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-github-oidc-role"

  name    = "${local.name_prefix}-actions-role"
  version = "5.34.0"


  subjects = [
    "repo:MoustafaAMahmoud/DataSquadPlatformLab:*"
  ]

  policies = {
    additional  = aws_iam_policy.github_oidc_ecr_additional.arn
    secret_cicd = aws_iam_policy.github_oidc_secret_cicd_additional.arn
    #ECRReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  }

  tags = merge(local.default_tags, {
    yor_name = "iam_github_oidc_role"
    Name     = "${local.name_prefix}-oidc-role"
    }
  )
}

################################################################################
# Supporting Resources
################################################################################

resource "aws_iam_policy" "github_oidc_ecr_additional" {
  name        = "${local.name_prefix}-actions-ecr-policy"
  description = "Additional github_oidc_additional ecr policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchGetImage",
          "ecr:GetLifecyclePolicy",
          "ecr:GetLifecyclePolicyPreview",
          "ecr:ListTagsForResource",
          "ecr:DescribeImageScanFindings",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/datasquad-app-api"
      },
      {
        "Effect" : "Allow",
        "Action" : "ecr:GetAuthorizationToken",
        "Resource" : "*"
      }
    ]
  })

  tags = merge(local.default_tags, {
    yor_name = "github_oidc_additional"
    Name     = "${local.name_prefix}-actions-additional-policy"
    }
  )
}

resource "aws_iam_policy" "github_oidc_secret_cicd_additional" {
  name        = "${local.name_prefix}-actions-secret-cicd-policy"
  description = "Additional github_oidc_additional ecr policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:DescribeSecret",
          "secretsmanager:PutSecretValue",
          "secretsmanager:CreateSecret",
          "secretsmanager:DeleteSecret",
          "secretsmanager:CancelRotateSecret",
          "secretsmanager:ListSecretVersionIds",
          "secretsmanager:UpdateSecret",
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:StopReplicationToReplica",
          "secretsmanager:ReplicateSecretToRegions",
          "secretsmanager:RestoreSecret",
          "secretsmanager:RotateSecret",
          "secretsmanager:UpdateSecretVersionStage",
          "secretsmanager:RemoveRegionsFromReplication"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:tf-datasquad-eks-app-api-cicd-*"
      }
    ]
  })

  tags = merge(local.default_tags, {
    yor_name = "github_oidc_secret_cicd_additional"
    Name     = "${local.name_prefix}-secret-cicd-policy"
    }
  )
}