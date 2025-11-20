########################################
# project_name
# - AWS 리소스 네이밍 prefix로 사용.
# - 하나의 프로젝트 묶음을 구분하는 데 유용.
########################################
variable "project_name" {
  type    = string
  default = "HappyMSP"
}


########################################
# region
# - Terraform이 AWS 리소스를 생성할 리전 설정.
# - default: ap-northeast-2 (서울)
########################################
variable "region" {
  type    = string
  default = "ap-northeast-2"
}
