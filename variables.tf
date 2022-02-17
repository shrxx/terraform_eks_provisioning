variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
  type    = string
}
variable "env_prefix" {
  default = "demo"
  type    = string
}
variable "instance_types" {
  default = ["t3.small"]
  type    = list(string)
}
variable "private_subnets" {
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  type    = list(string)
}
variable "public_subnets" {
  default = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  type    = list(string)
}
variable "public_key_location" {
  type = string
}
variable "ec2_ssh_key" {
  type = string
}
variable "k8s_cluster_version" {
  default = "1.21"
  type    = string
}
variable "k8s_worker_capacity_type" {
  default = "ON_DEMAND"
  type    = string
}
