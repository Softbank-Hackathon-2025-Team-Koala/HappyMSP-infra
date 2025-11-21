########################################
# VPC ID 출력
# - 다른 모듈 또는 사용자에게 VPC ID를 제공하기 위한 output 값.
# - terraform apply 후 "terraform output vpc_id" 로 확인 가능.
########################################
output "vpc_id" {
  value = module.vpc.vpc_id
}


########################################
# EKS 클러스터 이름 출력
# - kubectl, AWS CLI, ALB Controller 등에서 클러스터 이름이 필요할 때 사용.
########################################
output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}
