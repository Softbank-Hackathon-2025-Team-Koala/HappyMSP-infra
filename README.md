# 🚀 Terraform Infrastructure
본 레포지토리는 **AWS EKS 기반 마이크로서비스 배포 플랫폼**의 인프라를 Terraform으로 자동화하기 위해 구성되었습니다.
Terraform 코드를 통해
- VPC 및 네트워크 리소스 자동 생성
- EKS 클러스터 + Managed Node Group 구성
- AWS Load Balancer Controller & Metrics Server 설치

까지 **완전 자동화된 클러스터 구축**을 제공합니다.


<br>
<br>

# 🏗️ Architecture Overview
![Architecture Diagram](https://github.com/Softbank-Hackathon-2025-Team-Koala/HappyMSP-infra/blob/main/architecture-diagram.jpg)

본 인프라 구성은 **고가용성(High Availability)**, **확장성(Scalability)**, **보안성(Security)** 을 모두 고려한 AWS EKS 기반 아키텍처입니다.

### 🔹 핵심 특징

- **Multi-AZ Deployment**  
  EKS 클러스터 및 노드 그룹을 **여러 가용 영역(AZ)** 에 분산 배치하여 장애 발생 시 자동 복구와 고가용성을 보장합니다.

- **Auto Scaling Node Groups**  
  워크로드 트래픽 변화에 따라 **Managed Node Group의 자동 확장(Auto Scaling)** 이 이루어져 효율적인 리소스 활용이 가능합니다.

- **Private Subnet Security**  
  EKS 노드는 **Private Subnet** 내에 배치되어 외부 직접 접근이 차단되며, **NAT Gateway**를 통해서만 외부와 통신하도록 구성되어 있습니다.

- **AWS Load Balancer Controller Integration**  
  클러스터에 **AWS Load Balancer Controller(ALB Controller)** 를 설치하여 Ingress 생성 시 ALB가 자동으로 구성되며, 서비스별 **Path-based Routing**이 자동 적용됩니다.

<br>
<br>

# 📁 Repository Structure

```
.
├── main.tf
├── variables.tf
├── outputs.tf
├── provider-eks.tf             # EKS 생성용 Provider
├── provider-full.tf.disabled   # EKS 생성 후 활성화하는 Provider (Helm/K8s 포함)
└── modules
    ├── vpc/
    ├── eks/
    └── irsa-alb-controller/
```

<br>
<br>

# 🧩 Core Modules

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

## 4️⃣ Metrics Server Module (`modules/metrics-server`)

- EKS 클러스터에 Kubernetes Metrics Server를 설치하는 모듈
- Helm Chart(`kubernetes-sigs/metrics-server`) 기반으로 설치

<br>
<br>


# 🧱 Provider Files

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


<br>
<br>

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
