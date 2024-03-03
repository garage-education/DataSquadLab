resource "aws_iam_policy" "node_additional" {
  name        = "${local.name_prefix}-iam-policy-additional-EC2"
  description = "Example usage of node additional policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })


  tags = merge(local.default_tags, {
    Name = "${local.name_prefix}-iam-policy-additional-EC2"

    }, {
    git_commit           = "903a451eea0a98ae6c22950b4ac2f18d2be0c5aa"
    git_file             = "eu-west-1/03_eks/iam.tf"
    git_last_modified_at = "2024-01-28 11:45:05"
    git_last_modified_by = "malaa"
    git_modifiers        = "MoustafaAMahmoud"
    git_org              = "datasquadapp.ai"
    git_repo             = "datasquad-infra"
    yor_name             = "node_additional_policy"
    yor_trace            = "4c12fa10-6420-4ffa-8630-ec3920dac1c6"
  })
}

resource "aws_iam_policy" "additional_ecr_access" {
  name = "${local.name_prefix}-iam-policy-additional-ecr-access"

  description = "Allow ECR access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Resource" : "*",
        "Action" : [
          "ecr:GetRegistryPolicy",
          "ecr:DescribeImageScanFindings",
          "ecr:GetLifecyclePolicyPreview",
          "ecr:GetDownloadUrlForLayer",
          "ecr:DescribeRegistry",
          "ecr:DescribePullThroughCacheRules",
          "ecr:DescribeImageReplicationStatus",
          "ecr:GetAuthorizationToken",
          "ecr:ListTagsForResource",
          "ecr:ListImages",
          "ecr:BatchGetRepositoryScanningConfiguration",
          "ecr:GetRegistryScanningConfiguration",
          "ecr:GetAuthorizationToken*",
          "ecr:UntagResource",
          "ecr:BatchGetImage",
          "ecr:DescribeImages",
          "ecr:TagResource",
          "ecr:DescribeRepositories",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetRepositoryPolicy",
          "ecr:GetLifecyclePolicy"
        ]
      }
    ]
  })

  tags = merge(local.default_tags, {
    Name = "${local.name_prefix}-iam-policy-additional-ecr-access"

    }, {
    git_commit           = "903a451eea0a98ae6c22950b4ac2f18d2be0c5aa"
    git_file             = "eu-west-1/03_eks/iam.tf"
    git_last_modified_at = "2024-01-28 11:45:05"
    git_last_modified_by = "malaa"
    git_modifiers        = "MoustafaAMahmoud"
    git_org              = "datasquadapp.ai"
    git_repo             = "datasquad-infra"
    yor_name             = "additional_ecr_access_policy"
    yor_trace            = "4c12fa10-6420-4ffa-8630-ec3920dac1c6"
  })
}
