resource "kubernetes_manifest" "karpenter_awsnodetemplate" {
  manifest = {
    apiVersion = "karpenter.k8s.aws/v1alpha1"
    kind       = "AWSNodeTemplate"
    metadata   = { name = "default" }
    spec = {
      subnetSelector = { "kubernetes.io/cluster/${var.cluster_name}" = "owned" }
      securityGroupSelector = { "kubernetes.io/cluster/${var.cluster_name}" = "owned" }
    }
  }
}

resource "kubernetes_manifest" "karpenter_provisioner" {
  manifest = {
    apiVersion = "karpenter.sh/v1alpha5"
    kind       = "Provisioner"
    metadata   = { name = "default" }
    spec = {
      requirements = [
        {
          key      = "node.kubernetes.io/instance-type"
          operator = "In"
          values   = var.karpenter_instance_types
        }
      ]
      limits = {
        resources = { cpu = "1000" }
      }
      providerRef = { name = kubernetes_manifest.karpenter_awsnodetemplate.manifest["metadata"]["name"] }
      ttlSecondsAfterEmpty = var.karpenter_ttl_seconds_after_empty
    }
  }
}
