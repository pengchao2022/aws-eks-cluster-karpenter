output "karpenter_iam_role_arn" {
  value = aws_iam_role.karpenter.arn
}

output "karpenter_helm_release_name" {
  value = helm_release.karpenter.name
}

output "karpenter_namespace" {
  value = helm_release.karpenter.namespace
}

output "karpenter_provisioner_name" {
  value = kubernetes_manifest.karpenter_provisioner.manifest[0].metadata.name
}

output "karpenter_nodeclass_name" {
  value = kubernetes_manifest.karpenter_nodeclass.manifest[0].metadata.name
}
