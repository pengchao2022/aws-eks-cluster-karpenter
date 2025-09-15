variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "karpenter_namespace" {
  type        = string
  description = "Namespace for Karpenter"
  default     = "karpenter"
}

variable "karpenter_ttl_seconds_after_empty" {
  type        = number
  description = "TTL for empty nodes"
  default     = 30
}

variable "karpenter_instance_types" {
  type        = list(string)
  description = "Instance types for Karpenter nodes"
  default     = ["t3.medium"]
}
