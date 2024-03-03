module "vpc_cni_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name_prefix = "${local.name_prefix}-vpc-cni-irsa"

  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv6   = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }

  tags = merge(local.default_tags, {
    Name                 = "${local.name_prefix}-vpc-cni-irsa"
    git_commit           = "d148b623a13c6c836024a32ad546e621892febf6"
    git_file             = "eu-west-1/03_eks/irsa.tf"
    git_last_modified_at = "2024-01-28 16:36:48"
    git_modifiers        = "MoustafaAMahmoud"
    git_org              = "datasquadapp.ai"
    git_repo             = "datasquad-infra"
    yor_name             = "vpc_cni_irsa_role"
    yor_trace            = "29f14fd6-59de-4058-8649-bdb2b6580a4c"
    git_last_modified_by = "malaa"
  })
}

module "cert_manager_irsa_role" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version                       = "~> 5.0"
  role_name                     = "${local.name_prefix}-cert-manager-irsa"
  attach_cert_manager_policy    = true
  cert_manager_hosted_zone_arns = ["arn:aws:route53:::hostedzone/IClearlyMadeThisUp"]

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["cert-manager:cert-manager"]
    }
  }

  tags = merge(local.default_tags, {
    Name                 = "${local.name_prefix}-cert-manager-irsa"
    git_commit           = "5cadb9ef67f3db4d92f09ff7ae4c7aef101f37cd"
    git_file             = "eu-west-1/03_eks/irsa.tf"
    git_last_modified_at = "2024-01-29 00:10:45"
    git_modifiers        = "MoustafaAMahmoud"
    git_org              = "datasquadapp.ai"
    git_repo             = "datasquad-infra"
    yor_name             = "cert_manager_irsa_role"
    yor_trace            = "29f14fd6-59de-4058-8649-bdb2b6580a4c"
    git_last_modified_by = "malaa"
  })
}

module "ebs_csi_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name             = "${local.name_prefix}-ebs-csi-irsa"
  attach_ebs_csi_policy = true


  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = merge(local.default_tags, {
    Name                 = "${local.name_prefix}-ebs-csi-irsa"
    git_commit           = "d148b623a13c6c836024a32ad546e621892febf6"
    git_file             = "eu-west-1/03_eks/irsa.tf"
    git_last_modified_at = "2024-01-28 16:36:48"
    git_modifiers        = "MoustafaAMahmoud"
    git_org              = "datasquadapp.ai"
    git_repo             = "datasquad-infra"
    yor_name             = "ebs_csi_irsa_role"
    yor_trace            = "29f14fd6-59de-4058-8649-bdb2b6580a4c"
    git_last_modified_by = "malaa"
  })
}

module "external_dns_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "${local.name_prefix}-external-dns-irsa"

  attach_external_dns_policy    = true
  external_dns_hosted_zone_arns = ["arn:aws:route53:::hostedzone/IClearlyMadeThisUp"]

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:external-dns"]
    }
  }


  tags = merge(local.default_tags, {
    Name                 = "${local.name_prefix}-external-dns-irsa"
    git_commit           = "d148b623a13c6c836024a32ad546e621892febf6"
    git_file             = "eu-west-1/03_eks/irsa.tf"
    git_last_modified_at = "2024-01-28 16:36:48"
    git_modifiers        = "MoustafaAMahmoud"
    git_org              = "datasquadapp.ai"
    git_repo             = "datasquad-infra"
    yor_name             = "external_dns_irsa_role"
    yor_trace            = "29f14fd6-59de-4058-8649-bdb2b6580a4c"
    git_last_modified_by = "malaa"
  })
}