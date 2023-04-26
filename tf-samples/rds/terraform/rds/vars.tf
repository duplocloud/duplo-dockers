variable "region" {
  default = "us-west-2"
  type    = string
}

variable "s3_backend_region" {
  default = "us-west-2"
  type    = string
}


variable "postgres_db_engine_version" {
  type    = string
  default = "13.7"
}

variable "postgres_db_size" {
  type    = string
  default = "db.t3.micro"
}

variable "postgres_db_multi_az" {
  type    = bool
  default = false
}

variable "postgres_db_master_username" {
  type    = string
  default = "rodoadmin"
}

variable "postgres_db_encrypt_storage" {
  type    = bool
  default = true
}

