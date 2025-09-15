variable "aws_region" {
  description = "AWS region where the EKS cluster exists"
  type        = string
}

variable "cluster_name" {
  description = "Name of the existing EKS cluster"
  type        = string
}

variable "karpenter_instance_types" {
  description = "List of EC2 instance types Karpenter is allowed to launch"
  type        = list(string)
  default     = ["t3.medium", "t3.large"]
}

variable "karpenter_ttl_seconds_after_empty" {
  description = "TTL for empty nodes in seconds"
  type        = number
  default     = 30
}

variable "karpenter_namespace" {
  description = "Namespace where Karpenter will be installed"
  type        = string
  default     = "karpenter"
}

variable "karpenter_chart_version" {
  description = "Helm chart version for Karpenter"
  type        = string
  default     = "0.37.0"
}
