module "karpenter" {
  source       = "./terraform-karpenter-module" # 指向你的模块目录
  aws_region   = "us-east-1"
  cluster_name = "spring-eks-cluster"

  # 可选：自定义实例类型和 TTL
  karpenter_instance_types          = ["t3.micro"]
  karpenter_ttl_seconds_after_empty = 30
}
