############################################
# Kubernetes Service Account (IRSA 적용)
############################################

# AWS Load Balancer Controller용 Service Account
# - IAM Role과 연결되어 AWS 리소스를 조작할 권한 부여
resource "kubernetes_service_account" "controller_sa" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.lb_role.arn
    }
  }
}
