provider "aws" {
  region = var.aws_region
}

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = var.cluster_name
}

resource "local_file" "kubeconfig" {
  content = <<EOT
apiVersion: v1
clusters:
- cluster:
    server: ${data.aws_eks_cluster.this.endpoint}
    certificate-authority-data: ${data.aws_eks_cluster.this.certificate_authority[0].data}
  name: eks
contexts:
- context:
    cluster: eks
    user: eks
  name: eks
current-context: eks
kind: Config
preferences: {}
users:
- name: eks
  user:
    token: ${data.aws_eks_cluster_auth.this.token}
EOT
  filename = "${path.module}/kubeconfig_temp.yaml"
}

provider "kubernetes" {
  config_path = local_file.kubeconfig.filename
}

provider "helm" {
  kubernetes = kubernetes
}
