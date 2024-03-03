#module "eks_aws_auth" {
#  source                    = "terraform-aws-modules/eks/aws//modules/aws-auth"
#  version                   = "~> 20.0"
#  manage_aws_auth_configmap = true
#
#  aws_auth_users = [
#    {
#      userarn  = "arn:aws:iam::ACCOUNT_ID_TO_BE_CHANGED:user/terraform"
#      username = "terraform"
#      groups   = ["system:masters"]
#    },
#    {
#      userarn  = "arn:aws:iam::ACCOUNT_ID_TO_BE_CHANGED:user/malaa"
#      username = "malaa"
#      groups   = ["system:masters"]
#    }
#  ]
#}