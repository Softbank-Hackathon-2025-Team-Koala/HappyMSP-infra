############################################
# IAM Role for AWS Load Balancer Controller (IRSA)
############################################
# - 컨트롤러가 ALB/NLB 등을 생성·수정할 수 있는 권한을 제공

resource "aws_iam_role" "lb_role" {
  name = "${var.project_name}-lb-role"

  assume_role_policy = data.aws_iam_policy_document.lb_assume.json
}

# IRSA용 Assume Role Policy
# - ServiceAccount → IAM Role 연결 (OIDC 기반)
data "aws_iam_policy_document" "lb_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}

# ALB Controller 권한 정책 로드
resource "aws_iam_policy" "lb_policy" {
  name   = "${var.project_name}-lb-policy"
  policy = file("${path.module}/lb-controller-policy.json")
}

# IAM Role에 정책 부착
resource "aws_iam_role_policy_attachment" "lb_attach" {
  role       = aws_iam_role.lb_role.name
  policy_arn = aws_iam_policy.lb_policy.arn
}
