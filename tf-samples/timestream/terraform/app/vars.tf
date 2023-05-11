variable "region" {
  default = "us-west-2"
  type    = string
}

variable "tenant_name" {
  default = "pravin"
  type    = string
}


variable "s3_backend_region" {
  default = "us-west-2"
  type    = string
}


variable "db_name" {
  type    = string
  default = "db3"
}

variable "s3_bucket" {
  type    = string
  default = "db3"
}

