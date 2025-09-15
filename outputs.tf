output "karpenter_iam_role_arn" {
  description = "ARN of the IAM Role used by Karpenter"
  value       = aws_iam_role.karpenter.arn
}

output "karpenter_helm_release_name" {
  description = "Helm release name for Karpenter"
  value       = helm_release.karpenter.name
}

output "karpenter_namespace" {
  description = "Namespace where Karpenter is installed"
  value       = helm_release.karpenter.namespace
}

output "karpenter_provisioner_name" {
  description = "Name of the default Karpenter Provisioner"
  value       = kubernetes_manifest.karpenter_provisioner.manifest["metadata"]["name"]
}

output "karpenter_awsnodetemplate_name" {
  description = "Name of the AWSNodeTemplate used by Karpenter"
  value       = kubernetes_manifest.karpenter_awsnodetemplate.manifest["metadata"]["name"]
}
