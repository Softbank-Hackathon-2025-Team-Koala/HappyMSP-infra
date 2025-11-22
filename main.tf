######################################## 
# VPC 모듈 호출
########################################
module "vpc" {
  source       = "./modules/vpc"
  project_name = var.project_name

  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
}


########################################
# EKS 클러스터 모듈 호출
########################################
module "eks" {
  source          = "./modules/eks"
  project_name    = var.project_name
  vpc_id          = module.vpc.vpc_id
  public_subnets  = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets

  node_desired_size  = 2
  node_min_size      = 2
  node_max_size      = 4
  node_instance_type = "t3.small"

}


########################################
# ALB Controller (IRSA 기반 설치)
########################################
module "alb_controller" {
  source       = "./modules/alb-controller"
  project_name = var.project_name

  cluster_name = module.eks.cluster_name
  vpc_id       = module.vpc.vpc_id
  region       = var.region

  enabled = var.enable_addons && var.enable_alb_controller
}


########################################
# Metrics Server 설치
########################################
module "metrics_server" {
  source = "./modules/metrics-server"

  enabled = var.enable_addons && var.enable_alb_controller

  depends_on = [
    module.eks
  ]
}
