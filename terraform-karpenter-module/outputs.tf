output "karpenter_provisioner_name" {
  value = kubernetes_manifest.karpenter_provisioner.manifest[0].metadata.name
}

output "karpenter_nodeclass_name" {
  value = kubernetes_manifest.karpenter_nodeclass.manifest[0].metadata.name
}
