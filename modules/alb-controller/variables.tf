variable "project_name" {}
variable "region" {}
variable "cluster_name" {}
variable "vpc_id" {}
variable "enabled" {
  description = "ALB Controller 리소스 생성 여부"
  type        = bool
  default     = true
}
