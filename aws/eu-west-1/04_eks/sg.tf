resource "aws_security_group" "remote_access" {
  name        = "${local.name_prefix}-remote-access"
  description = "Allow remote SSH access"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.default_tags, { Name = "${local.name_prefix}-remote-access" }, {
    Env                  = "Prod"
    Name                 = "${local.name_prefix}-remote-access"
    yor_name             = "remote_access"
    yor_trace            = "cde02733-d32a-4c69-b501-9864616cd82f"
    git_last_modified_by = "malaa"
    git_modifiers        = "MoustafaAMahmoud"
    git_org              = "datasquadapp.ai"
    git_commit           = "95547feab5a8152e13e48996c0eda654c80cea46"
    git_file             = "eu-west-1/03_eks/sg.tf"
    git_last_modified_at = "2024-01-28 13:35:03"
    git_repo             = "datasquad-infra"
  })
}


resource "aws_security_group" "eks_additional" {
  name_prefix = "${local.name_prefix}-additional"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }

  tags = merge(local.default_tags, { Name = "${local.name_prefix}-additional" }, {
    git_commit           = "d148b623a13c6c836024a32ad546e621892febf6"
    git_file             = "eu-west-1/03_eks/sg.tf"
    git_last_modified_at = "2024-01-28 16:36:48"
    git_last_modified_by = "malaa"
    git_modifiers        = "MoustafaAMahmoud"
    git_org              = "datasquadapp.ai"
    git_repo             = "datasquad-infra"
    yor_name             = "eks_additional"
    yor_trace            = "0ef06e93-8aa1-490d-be22-aa3583de5052"
  })
}
