provider "aws" {
  region = var.aws_region
}

# 获取 EKS 集群信息
data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = var.cluster_name
}

# Kubernetes provider，使用 EKS data 构建 host/ca/token
provider "kubernetes" {
  alias = "eks"

  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

# Helm provider 零配置，不要 kubernetes {} block
provider "helm" {}
