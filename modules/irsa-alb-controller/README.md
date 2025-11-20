# module: `irsa-alb-controller`

본 모듈은 **EKS 클러스터에 AWS Load Balancer Controller(ALB Controller)를 설치하고**
**IRSA(IAM Roles for Service Accounts)** 를 구성하여
Kubernetes Service Account와 IAM Role을 안전하게 연동합니다.

## Features

- EKS 클러스터 OIDC Provider 자동 생성
- ALB Controller용 IAM Role 및 IAM Policy 생성
- IRSA 기반 Kubernetes ServiceAccount 구성
- Helm Chart로 AWS Load Balancer Controller 설치
- region, cluster name, VPC ID 등 파라미터 기반 유연한 설정 가능

## Module Structure

```
modules/
└── irsa-alb-controller/
    ├── main.tf                 # 공통 data source
    ├── oidc.tf                 # OIDC Provider 생성
    ├── iam.tf                  # IAM Role / Policy / Attachments
    ├── sa.tf                   # ServiceAccount (IRSA)
    ├── controller.tf           # Helm Release (ALB Controller)
    ├── variables.tf
    └── outputs.tf
```

## IRSA 흐름 요약

```
EKS Cluster
   └─ OIDC Provider 생성
       └─ IAM Role (sts:AssumeRoleWithWebIdentity)
           └─ ServiceAccount annotation에 Role ARN 매핑
                └─ Helm Chart로 배포된 ALB Controller Pod가 해당 IAM Role 사용
```

---

## Prerequisites

- EKS 클러스터가 존재해야 함
- EKS OIDC가 활성화되어 있어야 함 (본 모듈이 자동으로 처리함)
- Helm provider 설정 필요
