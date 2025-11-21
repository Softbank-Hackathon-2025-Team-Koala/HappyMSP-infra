########################################
# EKS 클러스터 생성
########################################
resource "aws_eks_cluster" "cluster" {
  name     = "${var.project_name}-eks"    # 클러스터 이름
  role_arn = aws_iam_role.eks_cluster.arn # iam.tf에서 만든 EKS Role

  # EKS Control Plane이 사용할 ENI를 생성할 서브넷 목록 지정
  vpc_config {
    subnet_ids              = concat(var.public_subnets, var.private_subnets)
    endpoint_private_access = true
    endpoint_public_access  = true
  }
}

########################################
# Node Group 생성
########################################
resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_role_arn   = aws_iam_role.eks_node.arn
  node_group_name = "${var.project_name}-node"
  subnet_ids      = var.private_subnets # 노드가 배치될 서브넷

  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
    min_size     = var.node_min_size
  }

  instance_types = [var.node_instance_type]

}
