#terraform {
#  required_providers {
#    duplocloud = {
#      version = "~> 0.7.5"
#      source = "duplocloud/duplocloud"
#    }
#  }
#}
#
#provider "aws" {
#  region = "us-west-2"
#}
#
#provider "duplocloud" {}
#
#locals {
#  tenant_name = var.tenant_name
#  tenant_id = data.duplocloud_tenant.this.id
#
#  account_id = data.duplocloud_aws_account.this.account_id
#  region =  data.duplocloud_tenant_aws_region.this.aws_region
#  availability_domain = var.availability_domain
##  zone_count = 2
#
#  config_s3_bucket = "duploservices-${local.tenant_name}-config-${local.account_id}"
#  env_name = coalesce(var.tenant_name, local.tenant_name)
#
#  sparkmaster_prefix = "${var.oci_spark_cluster_prefix}-sparkmaster"
##  sparkmaster_full_name = "duploservices-${local.tenant_name}-${var.oci_spark_cluster_prefix}-sparkmaster"
#  sparkslave_prefix = "${var.oci_spark_cluster_prefix}-sparkslave"
#  sparklivy_prefix = "${var.oci_spark_cluster_prefix}-sparklivy"
#  sparknotebook_prefix = "${var.oci_spark_cluster_prefix}-sparknotebook"
#}
#
#data "duplocloud_tenant" "this" {
#  name = local.tenant_name
#}
#
#data "duplocloud_aws_account" "this" {
#  tenant_id = local.tenant_id
#}
#
#data "duplocloud_tenant_aws_region" "this" {
#  tenant_id = local.tenant_id
#}
#
#
#
#resource "duplocloud_k8_secret" "mongodb" {
#  tenant_id = local.tenant_id
#  secret_type = "Opaque"
#  secret_name = "oci"
#  secret_data = jsonencode({
#    "oci_profile_user"                            = var.oci_profile_user,
#    "oci_profile_fingerprint"                     = var.oci_profile_fingerprint,
#    "oci_profile_tenancy"                         = var.oci_profile_tenancy,
#    "oci_profile_region"                          = var.oci_profile_region,
#    "oci_profile_key_file"                        = var.oci_profile_key_file,
#    "oci_profile_key"                             = file(var.oci_profile_key_local_path),
#  })
#}
#
#resource "duplocloud_oci_containerengine_node_pool" "oci-sparkmaster" {
#
#
#  name          = local.sparkmaster_prefix
#  tenant_id     = local.tenant_id
#  node_image_id = var.node_image_id
#  node_shape    = var.master_node_instance_type
#
#  node_config_details {
#    size = 1
#
#    placement_configs {
#      availability_domain = local.availability_domain
#      subnet_id           = var.subnetid
#    }
#
#    freeform_tags = {
#      CreatedBy = "duplo"
#      Spark = "master"
#    }
#  }
#
#  initial_node_labels {
#    key   = "allocationtags"
#    value = local.sparkmaster_prefix
#  }
#
#  lifecycle {
#     create_before_destroy = true
#     ignore_changes = [
#      node_config_details.0.freeform_tags,
#      defined_tags
#    ]
#  }
#
#   provisioner "local-exec" {
#    command = "sleep 120"
#  }
#
#}
#
#
#resource "duplocloud_oci_containerengine_node_pool" "oci-sparkslave" {
#
#  name          = local.sparkslave_prefix
#  tenant_id     = local.tenant_id
#  node_image_id = var.node_image_id
#  node_shape    = var.slave_node_instance_type
#
#  node_config_details {
#    size = var.oci_spark_cluster_slave_count
#
#    placement_configs {
#      availability_domain = local.availability_domain
#      subnet_id           = var.subnetid
#    }
#
#    freeform_tags = {
#      CreatedBy = "duplo"
#      Spark = "slave"
#    }
#  }
#
#  initial_node_labels {
#    key   = "allocationtags"
#    value = local.sparkslave_prefix
#  }
#
#  lifecycle {
#     create_before_destroy = true
#     ignore_changes = [
#      node_config_details.0.freeform_tags,
#      defined_tags
#    ]
#  }
#
#   provisioner "local-exec" {
#    command = "sleep 120"
#  }
#
#}
#
#resource "duplocloud_oci_containerengine_node_pool" "oci-sparklivy" {
#
#  name          = local.sparklivy_prefix
#  tenant_id     = local.tenant_id
#  node_image_id = var.node_image_id
#  node_shape    = var.livy_node_instance_type
#
#  node_config_details {
#    size = 1
#
#    placement_configs {
#      availability_domain = local.availability_domain
#      subnet_id           = var.subnetid
#    }
#
#    freeform_tags = {
#      CreatedBy = "duplo"
#      Spark = "livy"
#    }
#  }
#
#  initial_node_labels {
#    key   = "allocationtags"
#    value = local.sparklivy_prefix
#  }
#
#  lifecycle {
#     create_before_destroy = true
#     ignore_changes = [
#      node_config_details.0.freeform_tags,
#      defined_tags
#    ]
#  }
#
#   provisioner "local-exec" {
#    command = "sleep 120"
#  }
#
#}
#
#
#resource "duplocloud_oci_containerengine_node_pool" "oci-sparknotebook" {
#
#  name          = local.sparknotebook_prefix
#  tenant_id     = local.tenant_id
#  node_image_id = var.node_image_id
#  node_shape    = var.notebook_node_instance_type
#
#  node_config_details {
#    size = 1
#
#    placement_configs {
#      availability_domain = local.availability_domain
#      subnet_id           = var.subnetid
#    }
#
#    freeform_tags = {
#      CreatedBy = "duplo"
#      Spark = "notebook"
#    }
#  }
#
#  initial_node_labels {
#    key   = "allocationtags"
#    value = local.sparknotebook_prefix
#  }
#
#  lifecycle {
#     create_before_destroy = true
#     ignore_changes = [
#      node_config_details.0.freeform_tags,
#      defined_tags
#    ]
#  }
#
#   provisioner "local-exec" {
#    command = "sleep 120"
#  }
#
#}
#
#
#resource "duplocloud_duplo_service" "oci-sparkmaster" {
#  depends_on = [duplocloud_oci_containerengine_node_pool.oci-sparkmaster,
#       duplocloud_oci_containerengine_node_pool.oci-sparkslave, duplocloud_oci_containerengine_node_pool.oci-sparklivy]
#
#
#  lifecycle {
#    ignore_changes = [ docker_image ]
#  }
#
#  tenant_id = local.tenant_id
#
#  name           = local.sparkmaster_prefix
#  agent_platform = 7
#  cloud = 1
#
#  docker_image   = var.spark_master_docker_image
#  replicas = 1
#  allocation_tags = local.sparkmaster_prefix
#
#  other_docker_config = jsonencode({
#    HostNetwork = true,
#    Env = [
#      { Name = "DUPLO_SPARK_MASTER_IP", Value = "0.0.0.0" },
#      { Name = "DUPLO_SPARK_NODE_TYPE", Value = "master" },
#      { Name = "oci_profile_user", ValueFrom = { SecretKeyRef = { Name = duplocloud_k8_secret.oci.secret_name, Key = "oci_profile_user" } } },
#      { Name = "oci_profile_fingerprint", ValueFrom = { SecretKeyRef = { Name = duplocloud_k8_secret.oci.secret_name, Key = "oci_profile_fingerprint" } } },
#      { Name = "oci_profile_tenancy", ValueFrom = { SecretKeyRef = { Name = duplocloud_k8_secret.oci.secret_name, Key = "oci_profile_tenancy" } } },
#      { Name = "oci_profile_region", ValueFrom = { SecretKeyRef = { Name = duplocloud_k8_secret.oci.secret_name, Key = "oci_profile_region" } } },
#      { Name = "oci_profile_key_file", ValueFrom = { SecretKeyRef = { Name = duplocloud_k8_secret.oci.secret_name, Key = "oci_profile_key_file" } } },
#      { Name = "oci_profile_key", ValueFrom = { SecretKeyRef = { Name = duplocloud_k8_secret.oci.secret_name, Key = "oci_profile_key" } } },
#
#    ]
#  })
#}
#
#resource "duplocloud_duplo_service" "oci-sparkslave" {
# depends_on = [duplocloud_oci_containerengine_node_pool.oci-sparkmaster,
#       duplocloud_oci_containerengine_node_pool.oci-sparkslave, duplocloud_oci_containerengine_node_pool.oci-sparklivy]
#
#  lifecycle {
#    ignore_changes = [ docker_image ]
#  }
#
#  tenant_id = local.tenant_id
#  name  = local.sparkslave_prefix
#
#  agent_platform = 7
#  cloud = 1
#
#  docker_image   = var.spark_slave_docker_image
#  replicas = var.oci_spark_cluster_slave_count
#  allocation_tags = local.sparkslave_prefix
#
#  other_docker_config = jsonencode({
#    HostNetwork = true,
#    Env = [
#      { Name = "DUPLO_SPARK_MASTER_IP", Value = duplocloud_oci_containerengine_node_pool.oci-sparkmaster.nodes[0].private_ip },
#      { Name = "DUPLO_SPARK_LIVY_IP", Value = duplocloud_oci_containerengine_node_pool.oci-sparklivy.nodes[0].private_ip },
#      { Name = "DUPLO_SPARK_NODE_TYPE", Value = "worker" },
#      { Name = "oci_profile_user", ValueFrom = { SecretKeyRef = { Name = duplocloud_k8_secret.oci.secret_name, Key = "oci_profile_user" } } },
#      { Name = "oci_profile_fingerprint", ValueFrom = { SecretKeyRef = { Name = duplocloud_k8_secret.oci.secret_name, Key = "oci_profile_fingerprint" } } },
#      { Name = "oci_profile_tenancy", ValueFrom = { SecretKeyRef = { Name = duplocloud_k8_secret.oci.secret_name, Key = "oci_profile_tenancy" } } },
#      { Name = "oci_profile_region", ValueFrom = { SecretKeyRef = { Name = duplocloud_k8_secret.oci.secret_name, Key = "oci_profile_region" } } },
#      { Name = "oci_profile_key_file", ValueFrom = { SecretKeyRef = { Name = duplocloud_k8_secret.oci.secret_name, Key = "oci_profile_key_file" } } },
#      { Name = "oci_profile_key", ValueFrom = { SecretKeyRef = { Name = duplocloud_k8_secret.oci.secret_name, Key = "oci_profile_key" } } },
#
#    ]
#  })
#
#}
#
#resource "duplocloud_duplo_service" "oci-sparklivy" {
# depends_on = [duplocloud_oci_containerengine_node_pool.oci-sparkmaster,
#       duplocloud_oci_containerengine_node_pool.oci-sparkslave, duplocloud_oci_containerengine_node_pool.oci-sparklivy]
#
#  lifecycle {
#    ignore_changes = [ docker_image ]
#  }
#
#  tenant_id = local.tenant_id
#  name  = local.sparklivy_prefix
#
#  agent_platform = 7
#  cloud = 1
#
#  docker_image   = var.spark_livy_docker_image
#  replicas = 1
#  allocation_tags = local.sparklivy_prefix
#
#  other_docker_config = jsonencode({
#    HostNetwork = true,
#    Env = [
#      { Name = "DUPLO_SPARK_MASTER_IP", Value = duplocloud_oci_containerengine_node_pool.oci-sparkmaster.nodes[0].private_ip },
#      { Name = "DUPLO_SPARK_LIVY_IP", Value = duplocloud_oci_containerengine_node_pool.oci-sparklivy.nodes[0].private_ip },
#      { Name = "DUPLO_SPARK_NODE_TYPE", Value = "livy" },
#      { Name = "oci_profile_user", ValueFrom = { SecretKeyRef = { Name = duplocloud_k8_secret.oci.secret_name, Key = "oci_profile_user" } } },
#      { Name = "oci_profile_fingerprint", ValueFrom = { SecretKeyRef = { Name = duplocloud_k8_secret.oci.secret_name, Key = "oci_profile_fingerprint" } } },
#      { Name = "oci_profile_tenancy", ValueFrom = { SecretKeyRef = { Name = duplocloud_k8_secret.oci.secret_name, Key = "oci_profile_tenancy" } } },
#      { Name = "oci_profile_region", ValueFrom = { SecretKeyRef = { Name = duplocloud_k8_secret.oci.secret_name, Key = "oci_profile_region" } } },
#      { Name = "oci_profile_key_file", ValueFrom = { SecretKeyRef = { Name = duplocloud_k8_secret.oci.secret_name, Key = "oci_profile_key_file" } } },
#      { Name = "oci_profile_key", ValueFrom = { SecretKeyRef = { Name = duplocloud_k8_secret.oci.secret_name, Key = "oci_profile_key" } } },
#
#    ]
#  })
#
#}
#
#resource "duplocloud_duplo_service" "oci-sparknotebook" {
# depends_on = [duplocloud_oci_containerengine_node_pool.oci-sparkmaster,
#       duplocloud_oci_containerengine_node_pool.oci-sparkslave, duplocloud_oci_containerengine_node_pool.oci-sparklivy,
#        duplocloud_oci_containerengine_node_pool.oci-sparknotebook]
#
#  lifecycle {
#    ignore_changes = [ docker_image ]
#  }
#
#  tenant_id = local.tenant_id
#  name  = local.sparknotebook_prefix
#
#  agent_platform = 7
#  cloud = 1
#
#  docker_image   = var.spark_notebook_docker_image
#  replicas = 1
#  allocation_tags = local.sparknotebook_prefix
#
#  other_docker_config = jsonencode({
#    HostNetwork = true,
#    Env = [
#      { Name = "DUPLO_SPARK_MASTER_IP", Value = duplocloud_oci_containerengine_node_pool.oci-sparkmaster.nodes[0].private_ip },
#      { Name = "DUPLO_SPARK_LIVY_IP", Value = duplocloud_oci_containerengine_node_pool.oci-sparklivy.nodes[0].private_ip },
#      { Name = "DUPLO_SPARK_NODE_TYPE", Value = "notebook" },
#      { Name = "oci_profile_user", ValueFrom = { SecretKeyRef = { Name = duplocloud_k8_secret.oci.secret_name, Key = "oci_profile_user" } } },
#      { Name = "oci_profile_fingerprint", ValueFrom = { SecretKeyRef = { Name = duplocloud_k8_secret.oci.secret_name, Key = "oci_profile_fingerprint" } } },
#      { Name = "oci_profile_tenancy", ValueFrom = { SecretKeyRef = { Name = duplocloud_k8_secret.oci.secret_name, Key = "oci_profile_tenancy" } } },
#      { Name = "oci_profile_region", ValueFrom = { SecretKeyRef = { Name = duplocloud_k8_secret.oci.secret_name, Key = "oci_profile_region" } } },
#      { Name = "oci_profile_key_file", ValueFrom = { SecretKeyRef = { Name = duplocloud_k8_secret.oci.secret_name, Key = "oci_profile_key_file" } } },
#      { Name = "oci_profile_key", ValueFrom = { SecretKeyRef = { Name = duplocloud_k8_secret.oci.secret_name, Key = "oci_profile_key" } } },
#
#    ]
#  })
#
#}
#
#
#
#resource "local_file" "oci-sparkmaster-ip" {
#  depends_on = [duplocloud_oci_containerengine_node_pool.oci-sparkmaster]
#
#  content  =   duplocloud_oci_containerengine_node_pool.oci-sparkmaster.nodes[0].private_ip
#
#  filename = "${path.module}/../../../build/oci-sparkmaster-ip"
#}
#
#
#
#
#resource "local_file" "oci-sparklivy-ip" {
#  depends_on = [duplocloud_oci_containerengine_node_pool.oci-sparklivy]
#
#  content  =   duplocloud_oci_containerengine_node_pool.oci-sparklivy.nodes[0].private_ip
#
#  filename = "${path.module}/../../../build/oci-sparklivy-ip"
#}
#
#
#resource "local_file" "oci-sparknotebook-ip" {
#  depends_on = [duplocloud_oci_containerengine_node_pool.oci-sparknotebook]
#
#  content  =   duplocloud_oci_containerengine_node_pool.oci-sparknotebook.nodes[0].private_ip
#
#  filename = "${path.module}/../../../build/oci-sparknotebook-ip"
#}
#
#
#
