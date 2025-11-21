# EKS 클러스터 메타데이터 조회 (엔드포인트, CA 인증서 등)
data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

# Kubernetes API 서버 접근용 인증 토큰 조회
data "aws_eks_cluster_auth" "this" {
  name = var.cluster_name
}
