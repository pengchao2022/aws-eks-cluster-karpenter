variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "karpenter_namespace" {
  description = "Namespace for Karpenter"
  type        = string
  default     = "karpenter"
}

variable "karpenter_chart_version" {
  description = "Karpenter Helm chart version"
  type        = string
  default     = "0.33.2" # 请根据实际 Helm chart 版本调整
}

variable "karpenter_ttl_seconds_after_empty" {
  description = "TTL for empty nodes"
  type        = number
  default     = 30
}
variable "karpenter_instance_types" {
  description = "List of instance types for Karpenter nodes"
  type        = list(string)
  default     = ["t3.micro"]
}