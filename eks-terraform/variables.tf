variable "region" {
  default = "us-east-1"
}

variable "project" {
  type    = string
  default = "APP"
}

variable "environment" {
  type    = string
  default = "PROD"
}

variable "eksversion" {
  type    = string
  default = "1.21"
}
