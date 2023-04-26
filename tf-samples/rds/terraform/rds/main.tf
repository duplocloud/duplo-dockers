terraform {
  required_version = ">= 0.14.0"
  required_providers {
    duplocloud = {
      source  = "duplocloud/duplocloud"
      version = "~> 0.9.1"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.18.0"
    }
    local = {}
  }
}
provider "duplocloud" {

}
provider "aws" {
  region = var.region
}




resource "random_password" "rds_password" {
  length  = 16
  special = false
}

resource "duplocloud_rds_instance" "postgres" {
  tenant_id      = local.tenant_id
  name           = local.tenant_name
  engine         = 1
  engine_version = var.postgres_db_engine_version
  size           = var.postgres_db_size

  master_username = var.postgres_db_master_username
  master_password = random_password.rds_password.result

  encrypt_storage = var.postgres_db_encrypt_storage
  multi_az        = var.postgres_db_multi_az
}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [duplocloud_rds_instance.postgres]

  create_duration = "30s"
}

