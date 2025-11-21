########################################
# VPC 모듈 호출
# - 프로젝트에서 공통으로 사용할 네트워크 인프라(VPC, 서브넷 등)를 생성.
# - CIDR 블록과 서브넷 목록을 전달.
########################################
module "vpc" {
  source       = "./modules/vpc"  # 모듈이 위치한 로컬 경로
  project_name = var.project_name # 리소스 이름에 공통 prefix로 사용

  vpc_cidr             = "10.0.0.0/16"                    # 전체 VPC 주소 범위
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]   # 두 개의 퍼블릭 서브넷 CIDR
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"] # 두 개의 프라이빗 서브넷 CIDR
}


########################################
# EKS 클러스터 모듈 호출
# - 위에서 생성한 VPC 정보(VPC ID, 프라이빗 서브넷)를 입력으로 전달.
# - EKS는 보통 프라이빗 서브넷에 배치.
########################################
module "eks" {
  source          = "./modules/eks"   # EKS 모듈 경로
  project_name    = var.project_name  # 네이밍 prefix
  vpc_id          = module.vpc.vpc_id # vpc 모듈 output: VPC ID
  public_subnets  = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets # vpc 모듈 output: 프라이빗 서브넷 목록

  node_desired_size  = 2
  node_min_size      = 2
  node_max_size      = 4
  node_instance_type = "t3.small"

}


# #######################################
# ALB Controller (IRSA 기반 설치)
# - AWS Load Balancer Controller 설치 모듈
# - EKS Ingress를 ALB로 자동 매핑하기 위해 필요
# - 현재는 주석 처리됨. 필요 시 enable
# #######################################
module "alb_controller" {
  source       = "./modules/alb-controller" # ALB Controller 모듈 경로
  project_name = var.project_name           # prefix

  cluster_name = module.eks.cluster_name # EKS 클러스터 이름  
  vpc_id       = module.vpc.vpc_id       # VPC ID
  region       = var.region              # ALB Controller 배포 리전
}
