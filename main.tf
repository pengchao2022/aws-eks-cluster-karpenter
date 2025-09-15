##################################################
# 调用 Karpenter 模块
##################################################
module "karpenter" {
  source       = "./terraform-karpenter-module" # 模块路径，根据实际情况修改
  aws_region   = "us-east-1"
  cluster_name = "spring-eks-cluster"

  karpenter_instance_types          = ["t3.medium"]
  karpenter_ttl_seconds_after_empty = 60
}

##################################################
# 输出模块信息
##################################################
output "karpenter_iam_role_arn" {
  value = module.karpenter.karpenter_iam_role_arn
}

output "karpenter_helm_release_name" {
  value = module.karpenter.karpenter_helm_release_name
}

output "karpenter_namespace" {
  value = module.karpenter.karpenter_namespace
}

output "karpenter_provisioner_name" {
  value = module.karpenter.karpenter_provisioner_name
}

output "karpenter_nodeclass_name" {
  value = module.karpenter.karpenter_nodeclass_name
}
