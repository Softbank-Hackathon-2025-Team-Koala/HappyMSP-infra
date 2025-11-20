########################################
# Node Group 생성
########################################
resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_role_arn   = aws_iam_role.node_role.arn
  node_group_name = "${var.project_name}-node"
  subnet_ids      = var.private_subnets # 노드가 배치될 서브넷

  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 2
  }

  ami_type       = "AL2023_x86_64_STANDARD"
  instance_types = ["t3.small"] # 워커 노드 인스턴스 타입

}
