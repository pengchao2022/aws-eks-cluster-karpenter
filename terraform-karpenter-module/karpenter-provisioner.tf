resource "kubernetes_manifest" "karpenter_provisioner" {
  provider = kubernetes.eks

  depends_on = [
    kubernetes_manifest.karpenter_nodeclass
  ]

  manifest = {
    apiVersion = "karpenter.sh/v1alpha5"
    kind       = "Provisioner"
    metadata   = { name = "default" }
    spec = {
      requirements = [
        {
          key      = "instance-type"
          operator = "In"
          values   = var.karpenter_instance_types
        }
      ]
      limits = {
        resources = { cpu = "1000" }
      }
      providerRef          = { name = kubernetes_manifest.karpenter_nodeclass.manifest[0].metadata.name }
      ttlSecondsAfterEmpty = var.karpenter_ttl_seconds_after_empty
    }
  }
}
