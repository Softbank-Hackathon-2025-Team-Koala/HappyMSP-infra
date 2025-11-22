############################################
# AWS Load Balancer Controller 설치 (Helm)
############################################

# - EKS에서 Ingress → ALB 생성/관리 자동화
# - IRSA 기반 ServiceAccount를 사용하도록 설정
resource "helm_release" "aws_load_balancer_controller" {
  count = var.enabled ? 1 : 0

  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"

  # SA 및 IAM Role이 먼저 생성되어야 설치 가능
  depends_on = [
    kubernetes_service_account.controller_sa,
    aws_iam_role_policy_attachment.lb_attach
  ]

  # Helm chart 설정값 지정
  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "region"
    value = var.region
  }

  set {
    name  = "vpcId"
    value = var.vpc_id
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
}

