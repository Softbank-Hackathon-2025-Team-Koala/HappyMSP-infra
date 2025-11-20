########################################
# EKS 클러스터 생성
########################################
resource "aws_eks_cluster" "cluster" {
  name     = "${var.project_name}-eks" # 클러스터 이름
  role_arn = aws_iam_role.eks_role.arn # iam.tf에서 만든 EKS Role

  vpc_config {
    subnet_ids = var.private_subnets # Control Plane이 접근할 서브넷
  }
}
