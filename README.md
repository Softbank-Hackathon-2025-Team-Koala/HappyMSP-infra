# 🚀 Terraform EKS Infrastructure

**AWS EKS 기반 마이크로서비스 배포 플랫폼** 인프라 구축을 위한 Terraform 구성입니다.

이 레포지토리는 다음을 목표로 합니다.

- 공통 네트워크(VPC) 인프라 자동 생성
- EKS 클러스터 및 NodeGroup 생성
- 클러스터에 AWS Load Balancer Controller 및 Metrics Server 설치

# 📁 Repository Structure

```
.
├── main.tf
├── variables.tf
├── outputs.tf
├── provider-eks.tf             # EKS만 먼저 생성
├── provider-full.tf.disabled   # EKS + Kubernetes/Helm 리소스까지 포함
└── modules
    ├── vpc/
    ├── eks/
    └── irsa-alb-controller/
```

# 🧩 Core Modules Overview

## 1️⃣ VPC Module (`modules/vpc`)

- 전용 VPC 생성
- 2개의 Public Subnet + 2개의 Private Subnet
- NAT Gateway / Internet Gateway 구성
- EKS가 사용할 Subnet을 모듈 output으로 제공

## 2️⃣ EKS Module (`modules/eks`)

- 프라이빗 서브넷을 기반으로 하는 EKS 클러스터 생성
- IAM Role(EKS Control Plane / NodeGroup) 포함
- 관리형 Node Group 생성

## 3️⃣ IRSA 기반 AWS Load Balancer Controller (`modules/alb-controller`)

- ALB Ingress Controller를 EKS에 배포하는 모듈
- IRSA(OIDC) 기반 IAM Role + ServiceAccount 구성
- Helm을 통해 설치

이 모듈은 다음 변수들로 설치 여부를 제어합니다.

```hcl
variable "enable_addons" {
  description = "EKS 애드온(ALB Controller, Metrics Server) 설치 여부"
  type        = bool
  default     = false
}

variable "enable_alb_controller" {
  description = "AWS Load Balancer Controller 설치 여부"
  type        = bool
  default     = false
}
```

`main.tf`

```hcl
module "alb_controller" {
  source       = "./modules/alb-controller"
  project_name = var.project_name

  cluster_name = module.eks.cluster_name
  vpc_id       = module.vpc.vpc_id
  region       = var.region

  enabled = var.enable_addons && var.enable_alb_controller
}
```

➜ `enable_addons` 및 `enable_alb_controller` 가 모두 true일 때만 실제 리소스가 생성됩니다.

## 4️⃣ Metrics Server Module (modules/metrics-server)

- EKS 클러스터에 Kubernetes Metrics Server를 설치하는 모듈
- Helm Chart(`kubernetes-sigs/metrics-server`) 기반으로 설치

<br>
<br>

# 🧱 Provider Files (중요)

**AWS 리소스를 만드는 Provider**와
**EKS 내부(Kubernetes/Helm)에 리소스를 설치하는 Provider** 두 단계로 구성되어 있습니다.

## 🟦 provider-eks.tf

- EKS 클러스터를 먼저 생성하기 위해 사용할 Provider 구성

```bash
terraform apply -target=module.vpc -target=module.eks
```

## 🟩 provider-full.tf (현재 .disabled)

- EKS가 생성된 후 사용할 전체 Provider 구성
- ALB Controller, Metrics Server 같은 클러스터 내부 컴포넌트 설치에 사용됩니다.
- EKS 클러스터 생성 후 파일명을 `provider-full.tf` 로 바꿔 활성화하여 사용할 수 있습니다.

```bash
terraform apply \
  -var="enable_addons=true" \
  -var="enable_alb_controller=true" \
  -var="enable_metrics_server=true"
```

> ⚠️ provider-full.tf 는 EKS 클러스터 정보(cluster_endpoint, CA 등)에 의존하므로
> 클러스터 생성이 끝난 뒤 사용하는 것이 안전합니다.

# 🔧 Deployment Flow

## 1️⃣ 1단계 – VPC + EKS 인프라만 먼저 생성

```bash
# provider-eks.tf 활성화
terraform init
terraform apply -target=module.vpc -target=module.eks
```

## 2️⃣ 2단계 – ALB Controller + Metrics Server 설치

```bash
# provider-full.tf 활성화
terraform apply \
  -var="enable_addons=true" \
  -var="enable_alb_controller=true" \
  -var="enable_metrics_server=true"
```

필요에 따라 특정 컴포넌트만 켜고 싶다면:

```bash
# ALB Controller만
terraform apply \
  -var="enable_addons=true" \
  -var="enable_alb_controller=true" \
  -var="enable_metrics_server=false"

# Metrics Server만
terraform apply \
  -var="enable_addons=true" \
  -var="enable_alb_controller=false" \
  -var="enable_metrics_server=true"
```
