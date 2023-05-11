terraform {
//  required_version = "~> 0.14"
  required_providers {
    duplocloud = {
      #version = "~> 0.11.28"
      version = "~> 0.9.30"
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
  db_name  = "${var.db_name}-db"
  duplo_db_name  = "duploservices-${data.duplocloud_tenant.this.name}-${var.db_name}-db"
  table_name  = "d${var.db_name}-tble"

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

data "duplocloud_tenant_aws_kms_key" "kms_key" {
  tenant_id = local.tenant_id
}

resource "duplocloud_aws_timestreamwrite_database" "db" {
  tenant_id  = local.tenant_id
  name       = local.db_name
  kms_key_id = data.duplocloud_tenant_aws_kms_key.kms_key.key_arn
  tags {
        key   = "pro"
        value = "test"
    }
    tags {
        key   = "pro2"
        value = "test"
    }
}

resource "duplocloud_aws_timestreamwrite_table" "table" {
  depends_on = [duplocloud_aws_timestreamwrite_database.db]
  tenant_id     = local.tenant_id
  database_name = local.duplo_db_name
  name          = local.table_name
  magnetic_store_write_properties {
        enable_magnetic_store_writes = true
        magnetic_store_rejected_data_location {
          s3_configuration {
            bucket_name       = var.s3_bucket
            object_key_prefix = "error"
          }
        }
    }
    retention_properties {
        magnetic_store_retention_period_in_days = 1
        memory_store_retention_period_in_hours  = 1
    }
    tags {
        key   = "pro"
        value = "test"
    }
    tags {
        key   = "pro2"
        value = duplocloud_aws_timestreamwrite_database.db.name
    }
}