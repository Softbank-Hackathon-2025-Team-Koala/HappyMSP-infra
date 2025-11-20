resource "aws_eks_cluster" "cluster" {
    name = "${var.project_name}-eks
    role_arn = aws_iam_role.eks_role.arn

    vpc_config {
        subnet_ids = var.private_subnets
    }
}