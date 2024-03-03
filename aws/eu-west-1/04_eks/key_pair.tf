module "key_pair" {
  source  = "terraform-aws-modules/key-pair/aws"
  version = "~> 2.0"

  key_name_prefix    = local.name_prefix
  create_private_key = true
  #  key_name           = local.name_prefix

  tags = merge(local.default_tags, {
    Name = "${local.name_prefix}-key-pair"
    }, {
    git_commit           = "903a451eea0a98ae6c22950b4ac2f18d2be0c5aa"
    git_file             = "eu-west-1/03_eks/key_pair.tf"
    git_last_modified_at = "2024-01-28 11:45:05"
    git_last_modified_by = "malaa"
    git_modifiers        = "MoustafaAMahmoud"
    git_org              = "datasquadapp.ai"
    git_repo             = "datasquad-infra"
    yor_name             = "key_pair"
    yor_trace            = "2954cce3-d376-42ef-b0fc-5e77f64b7cd6"
  })
}
