terraform {
//  required_version = "~> 0.14"
  required_providers {
    duplocloud = {
      #version = "~> 0.11.28"
      version = "~> 0.9"
      source = "duplocloud/duplocloud"
    }
//    helm = { version = "~> 2.0" }
  }
}

provider "aws" {
  region = "us-west-2"
}

provider "duplocloud" {}

locals {
  tenant_name = var.tenant_name
  tenant_id = data.duplocloud_tenant.this.id

  account_id = data.duplocloud_aws_account.this.account_id
  region = data.duplocloud_tenant_aws_region.this.aws_region
  zone_count = 2
  pg_db_name  = "pg-${var.db_name}-w1"
  pg_replica_db_name  = "pg-${var.db_name}-r1"

  au_mysql_db_name  = "aumysql-${var.db_name}-w1"
  au_mysql_replica_db_name  = "aumysql-${var.db_name}-r1"
}

data "duplocloud_tenant" "this" {
  name = local.tenant_name
}

data "duplocloud_aws_account" "this" {
  tenant_id = local.tenant_id
}

data "duplocloud_tenant_aws_region" "this" {
  tenant_id = local.tenant_id
}

resource "random_password" "rds_password" {
  length  = 16
  special = false
}

resource "duplocloud_rds_instance" "postgres" {
  tenant_id      = local.tenant_id
  name           = local.pg_db_name
  engine         = 1
  engine_version = var.postgres_db_engine_version
  size           = var.postgres_db_size

  master_username = var.postgres_db_master_username
  master_password = random_password.rds_password.result

  encrypt_storage = var.postgres_db_encrypt_storage
  multi_az        = var.postgres_db_multi_az
  deletion_protection = false
}

resource "duplocloud_rds_read_replica" "postgresreplica" {
  tenant_id          = duplocloud_rds_instance.postgres.tenant_id
  name               = local.pg_replica_db_name
  size               = var.postgres_db_size
  cluster_identifier = duplocloud_rds_instance.postgres.cluster_identifier
}




resource "duplocloud_rds_instance" "au_mysql" {
  tenant_id      = local.tenant_id
  name           = local.au_mysql_db_name
  engine         = 8
  engine_version = var.au_mysql_db_engine_version
  size           = var.au_mysql_db_size

  master_username = var.postgres_db_master_username
  master_password = random_password.rds_password.result

  encrypt_storage = var.postgres_db_encrypt_storage
  deletion_protection = false
}

resource "duplocloud_rds_read_replica" "au_mysql" {
  tenant_id          = duplocloud_rds_instance.au_mysql.tenant_id
  name               = local.au_mysql_replica_db_name
  size               = var.au_mysql_db_size
  cluster_identifier = duplocloud_rds_instance.au_mysql.cluster_identifier
}


resource "time_sleep" "wait_30_seconds" {
  depends_on = [duplocloud_rds_instance.postgres]

  create_duration = "30s"
}

