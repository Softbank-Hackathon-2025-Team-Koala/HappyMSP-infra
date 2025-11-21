############################################
# OIDC Provider 생성 (IRSA 활성화용)
############################################

# EKS OIDC Issuer의 TLS 인증서 정보 조회
data "tls_certificate" "eks" {
  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}

# IAM OIDC Provider 등록
# - IRSA 사용을 위해 반드시 필요
resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}
