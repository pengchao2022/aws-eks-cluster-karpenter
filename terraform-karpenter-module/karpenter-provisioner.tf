##################################################
# 等待 Karpenter CRD 安装完成
##################################################
resource "null_resource" "wait_for_crd" {
  provisioner "local-exec" {
    command = <<EOT
until kubectl get crd nodeclasses.karpenter.sh &>/dev/null; do
  echo "Waiting for Karpenter CRD..."
  sleep 5
done
EOT
  }
}

##################################################
# NodeClass
##################################################
resource "kubernetes_manifest" "karpenter_nodeclass" {
  provider = kubernetes.eks

  depends_on = [
    helm_release.karpenter,
    null_resource.wait_for_crd
  ]

  manifest = {
    apiVersion = "karpenter.sh/v1alpha5"
    kind       = "NodeClass"
    metadata   = { name = "default" }
    spec = {
      provider = {
        subnetSelector        = { "kubernetes.io/cluster/${var.cluster_name}" = "owned" }
        securityGroupSelector = { "kubernetes.io/cluster/${var.cluster_name}" = "owned" }
      }
    }
  }
}

##################################################
# Provisioner
##################################################
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
      limits               = { resources = { cpu = "1000" } }
      providerRef          = { name = kubernetes_manifest.karpenter_nodeclass.manifest[0].metadata.name }
      ttlSecondsAfterEmpty = var.karpenter_ttl_seconds_after_empty
    }
  }
}
