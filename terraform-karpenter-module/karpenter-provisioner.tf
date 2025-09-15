resource "kubernetes_manifest" "karpenter_awsnodetemplate" {
  provider = kubernetes.eks

  depends_on = [
    helm_release.karpenter
  ]

  manifest = {
    apiVersion = "karpenter.sh/v1alpha5"
    kind       = "AWSNodeTemplate"
    metadata   = { name = "default" }
    spec = {
      subnetSelector        = { "kubernetes.io/cluster/${var.cluster_name}" = "owned" }
      securityGroupSelector = { "kubernetes.io/cluster/${var.cluster_name}" = "owned" }
    }
  }
}

resource "kubernetes_manifest" "karpenter_provisioner" {
  provider = kubernetes.eks

  depends_on = [
    kubernetes_manifest.karpenter_awsnodetemplate
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
      providerRef          = { name = kubernetes_manifest.karpenter_awsnodetemplate.manifest[0].metadata.name }
      ttlSecondsAfterEmpty = var.karpenter_ttl_seconds_after_empty
    }
  }
}
