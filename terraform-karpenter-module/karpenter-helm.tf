resource "helm_release" "karpenter" {
  provider         = helm
  name             = "karpenter"
  namespace        = var.karpenter_namespace
  create_namespace = true

  chart   = "oci://public.ecr.aws/karpenter/karpenter"
  version = "1.6.3"
  wait    = true
  timeout = 600

  values = [
    yamlencode({
      settings = {
        clusterName           = var.cluster_name
        clusterEndpoint       = data.aws_eks_cluster.this.endpoint
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
