variable "project_name" {}
variable "public_subnets" {}
variable "private_subnets" {}
variable "vpc_id" {}
variable "node_desired_size" {
  type    = number
  default = 2
}

variable "node_min_size" {
  type    = number
  default = 2
}

variable "node_max_size" {
  type    = number
  default = 4
}

variable "node_instance_type" {
  type    = string
  default = "t3.small"
}
