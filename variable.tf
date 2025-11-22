variable "project_name" {
  type    = string
  default = "HappyMSP"
}

variable "region" {
  type    = string
  default = "ap-northeast-2"
}

########################################
# Add-on 설치 여부 제어 변수
########################################

# 전체 애드온(알비 컨트롤러 + 메트릭 서버)을 켤지 여부
variable "enable_addons" {
  description = "EKS 애드온(ALB Controller, Metrics Server) 설치 여부"
  type        = bool
  default     = false
}

variable "enable_alb_controller" {
  description = "AWS Load Balancer Controller 설치 여부"
  type        = bool
  default     = true
}

variable "enable_metrics_server" {
  description = "metrics-server 설치 여부"
  type        = bool
  default     = true
}
