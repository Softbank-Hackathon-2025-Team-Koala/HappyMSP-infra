# 🚀 Terraform EKS Infrastructure

AWS EKS 기반 마이크로서비스 배포 인프라 구축을 위한 Terraform 구성입니다.

이 레포지토리는 다음을 목표로 합니다.

- 공통 네트워크(VPC) 인프라 자동 생성
- 전용 ECR 레지스트리 생성
- EKS 클러스터 및 NodeGroup 생성
- 클러스터에 AWS Load Balancer Controller 설치

# 📁 Repository Structure

```
.
├── main.tf
├── variables.tf
├── outputs.tf
├── provider-eks.tf         # EKS/VPC/ECR 생성만 하는 provider
├── provider-full.tf             # EKS 이후 Kubernetes/Helm 설치까지 포함
└── modules
    ├── vpc/
    ├── ecr/
    ├── eks/
    └── irsa-alb-controller/
```

# 🧩 Core Modules Overview

## 1️⃣ VPC Module

- 전용 VPC 생성
- 2개의 Public Subnet + 2개의 Private Subnet
- NAT Gateway / Internet Gateway 구성
- EKS가 사용할 Subnet을 모듈 output으로 제공

Outputs:

```
vpc_id
private_subnets
public_subnets
```

## 2️⃣ ECR Module

- 프로젝트 전용 ECR Repository 생성
- 서비스별 Docker 이미지를 push하는 저장소로 사용

Outputs:

```
repository_url
```


## 3️⃣ EKS Module

- 프라이빗 서브넷을 기반으로 하는 EKS 클러스터 생성
- IAM Role(EKS Control Plane / NodeGroup) 포함
- 관리형 Node Group 생성

Outputs:

```
cluster_name
cluster_endpoint
```


## 4️⃣ IRSA 기반 AWS Load Balancer Controller

- ALB Ingress Controller를 EKS에 배포하는 모듈
- IRSA(OIDC) 기반 IAM 연결 사용
- Helm을 통해 설치

⚠️ **중요: main.tf에서는 기본적으로 주석 처리됨**
→ EKS 클러스터가 완전히 준비된 후 활성화해야 함
→ provider-full.tf와 연결되지 않은 상태에서 enable하면 apply 실패 가능


# 🧱 Provider Files (중요)

**AWS 리소스를 만드는 Provider**와
**EKS 내부(Kubernetes/Helm)에 리소스를 설치하는 Provider** 두 단계를 분리했다.


## 🟦 provider-eks.tf

EKS 클러스터를 "먼저" 생성하기 위한 최소한의 provider 구성.
```bash
terraform apply -target=module.vpc -target=module.eks -target=module.ecr
```


## 🟩 provider-full.tf

EKS가 생성된 후,
Kubernetes Provider & Helm Provider를 활성화하여
클러스터 내부에 AWS LoadBalancer Controller 설치


# ⚠️ ALB Controller 모듈 사용 시 주의사항

main.tf:

```hcl
module "alb_controller" {
  source = "./modules/irsa-alb-controller"

  cluster_name     = module.eks.cluster_name
  cluster_endpoint = module.eks.cluster_endpoint
  vpc_id           = module.vpc.vpc_id
  project_name     = var.project_name
  region           = var.region
}
```

AWS Load Balancer Controller는 다음이 만족될 때만 활성화해야 한다.

- **provider-full.tf가 활성화된 상태여야 함**
- EKS 클러스터와 노드그룹이 생성되어있어야 함


# 🔧 Deployment Flow

```
1. terraform init
2. terraform apply -target=module.vpc -target=module.eks -target=module.ecr   (provider-eks)
3. aws eks update-kubeconfig
4. terraform apply   (provider-full + ALB Controller 주석 해제)
```
