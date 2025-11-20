# module: eks

본 모듈은 AWS EKS 클러스터 및 Node Group을 생성하고,
EKS가 동작하기 위한 IAM Role을 함께 구성합니다.

## Features

- EKS Control Plane 생성
- Managed Node Group 생성
- Control Plane 및 Node 용 IAM Role 자동 생성
- Private Subnet 기반 클러스터 구성
- 확장 가능하도록 변수 기반 설정 구조

## Module Structure

```
modules/
└── eks/
    ├── main.tf          # EKS 클러스터 + Node Group 정의
    ├── iam.tf           # Control Plane / Node Group IAM Role
    ├── variables.tf
    └── outputs.tf
```

## IAM 구성 요약

**Control Plane IAM Role**

- EKS 자체 리소스 관리 권한
- `"sts:AssumeRole"`
- Principal: `eks.amazonaws.com`

**Node Group IAM Role**

- EC2 노드가 AWS 리소스(S3, CloudWatch 등)에 접근
- `"sts:AssumeRole"`
- Principal: `ec2.amazonaws.com`

## Managed Node Group 설정

기본 설정:

- Desired size: 2
- Min: 2
- Max: 4
- Instance type: `t3.micro`
- AMI: `BOTTLEROCKET_x86_64`

  - AWS 보안 기반 OS, EKS 최적화 OS

## 아키텍처 개요

```
VPC
 └─ Private Subnets
      ├─ EKS Control Plane (managed by AWS)
      └─ EKS Managed Node Group (EC2 Worker Nodes)
```
