terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.22"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
  }
}

########################################
# AWS Provider 설정
# - Terraform이 AWS 리소스를 생성/조회할 때 사용할 리전(region)을 지정.
########################################
provider "aws" {
  region = var.region # variables.tf에서 정의한 AWS 리전
}


########################################
# EKS 클러스터 정보 조회 (Data Source)
# - Terraform이 이미 생성된 EKS 클러스터의 정보를 읽기 위해 사용.
# - 클러스터 엔드포인트(URL), CA 인증서, 상태 등을 얻을 수 있음.
########################################
data "aws_eks_cluster" "this" {
  name = module.eks.cluster_name
}


########################################
# EKS 인증 토큰 조회 (Data Source)
# - kubectl 또는 Kubernetes provider가 클러스터에 접근할 때 필요한 인증 토큰.
########################################
data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}


########################################
# Kubernetes Provider 설정
# - Terraform이 Kubernetes API 서버와 통신해 Deployment, Service 등 K8s 리소스를 생성.
# - EKS 클러스터 정보를 읽어 API 서버에 접근.
########################################
provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint                                    # EKS API 서버 엔드포인트
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data) # 인증서
  token                  = data.aws_eks_cluster_auth.this.token                                  # 인증 토큰
}


########################################
# Helm Provider 설정
# - Terraform이 Helm chart를 설치할 수 있도록 설정.
# - AWS Load Balancer Controller 설치 시 사용.
########################################
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}
