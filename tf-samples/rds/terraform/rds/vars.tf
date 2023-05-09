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


variable "postgres_db_engine_version" {
  type    = string
  default = "13.7"
}

variable "db_name" {
  type    = string
  default = "db3"
}

variable "postgres_db_size" {
  type    = string
  default = "db.t3.micro"
}

variable "au_mysql_db_engine_version" {
  type    = string
  default = "8.0.mysql_aurora.3.02.3"
}

variable "au_mysql_db_size" {
  type    = string
  default = "db.t3.medium"
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

