resource "helm_release" "karpenter" {
  name             = "karpenter"
  namespace        = var.karpenter_namespace
  create_namespace = true
  repository       = "https://charts.karpenter.sh/"
  chart            = "karpenter"
  version          = var.karpenter_chart_version

  values = [
    yamlencode({
      settings = {
        clusterName          = var.cluster_name
        clusterEndpoint      = data.aws_eks_cluster.this.endpoint
        interruptionQueueName = "${var.cluster_name}-karpenter-interruption-queue"
      }
      serviceAccount = {
        annotations = {
          "eks.amazonaws.com/role-arn" = aws_iam_role.karpenter.arn
        }
      }
    })
  ]
}
