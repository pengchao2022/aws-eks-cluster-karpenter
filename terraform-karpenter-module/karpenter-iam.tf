resource "aws_iam_role" "karpenter" {
  name               = "${var.cluster_name}-karpenter-role"
  assume_role_policy = file("${path.module}/karpenter-policy.json")
}

resource "aws_iam_role_policy_attachment" "karpenter_attach" {
  role       = aws_iam_role.karpenter.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterAutoscalerPolicy"
}
