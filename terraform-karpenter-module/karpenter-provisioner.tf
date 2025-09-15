##################################################
# 等待 Karpenter CRD 安装完成
##################################################
resource "null_resource" "wait_for_crd" {
  provisioner "local-exec" {
    command = <<EOT
set -e
echo "Waiting for Karpenter CRD to be ready..."
for i in {1..60}; do
  if kubectl get crd nodeclasses.karpenter.sh &>/dev/null; then
    echo "CRD is ready!"
    exit 0
  fi
  echo "CRD not ready yet, sleeping 5s..."
  sleep 5
done
echo "CRD did not become ready in time"
exit 1
EOT
    environment = {
      KUBECONFIG = "${path.module}/kubeconfig_temp.yaml" # 指向你生成的 kubeconfig 文件
    }
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
