############################################
# - EKS 클러스터에 metrics-server 설치
# - helm provider는 root(provider-full.tf)에서 공통으로 사용
############################################

resource "helm_release" "metrics_server" {
  count = var.enabled ? 1 : 0

  name      = "metrics-server"
  namespace = "kube-system"

  # 공식 metrics-server 차트 레포지토리
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"

  # 필요에 따라 버전 고정 (예시 버전)
  # - 헬름 repo에서 최신 버전 한 번 확인해서 맞게 바꿔도 됨
  version = "3.12.2"

  # EKS 환경에서 자주 쓰는 args 설정
  set {
    name  = "args[0]"
    value = "--kubelet-insecure-tls"
  }

  set {
    name  = "args[1]"
    value = "--kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname"
  }
}
