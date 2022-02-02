terraform {
//  required_version = "~> 0.14"
  required_providers {
    duplocloud = {
      version = "~> 0.7.1"
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
  tenant_name = "sparkdemo"
  tenant_id = data.duplocloud_tenant.this.id

  account_id = data.duplocloud_aws_account.this.account_id
  region = data.duplocloud_tenant_aws_region.this.aws_region
  zone_count = 2

  config_s3_bucket = "duploservices-${local.tenant_name}-config-${local.account_id}"
  env_name = coalesce(var.env_names[local.tenant_name], local.tenant_name)

  sparkmaster_prefix = "${var.eks_spark_cluster_prefix}-sparkmaster"
  sparkmaster_full_name = "duploservices-${local.tenant_name}-${var.eks_spark_cluster_prefix}-sparkmaster"
  sparkslave_prefix = "${var.eks_spark_cluster_prefix}-sparkslave"
  sparklivy_prefix = "${var.eks_spark_cluster_prefix}-sparklivy"
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

// EKS nodes, spread evenly across zones.
resource "duplocloud_aws_host" "eks-sparkmaster" {

  lifecycle {
    create_before_destroy = true
    ignore_changes = [ metadata ]
  }

  user_account = local.tenant_name
  tenant_id    = local.tenant_id

  friendly_name  = local.sparkmaster_prefix

  image_id       = var.eks_node_image_name
  capacity       = var.eks_node_instance_type
  agent_platform = 7
  minion_tags {
    key   = "AllocationTags"
    value = local.sparkmaster_prefix
  }
  tags {
    key   = "spark"
    value = "master"
  }
  tags {
    key   = "sparkcluster-prefix"
    value = var.eks_spark_cluster_prefix
  }
  provisioner "local-exec" {
    command = "sleep 30"
  }
}

resource "duplocloud_aws_host" "eks-sparkslave" {
  count = var.eks_spark_cluster_slave_count

  lifecycle {
    create_before_destroy = true
    ignore_changes = [ metadata ]
  }

  user_account = local.tenant_name
  tenant_id    = local.tenant_id

  friendly_name  = "${local.sparkslave_prefix}-${count.index + 1}"

  image_id       = var.eks_node_image_name
  capacity       = var.eks_node_instance_type
  agent_platform = 7
  minion_tags {
    key   = "AllocationTags"
    value = local.sparkslave_prefix
  }
  tags {
    key   = "spark"
    value = "slave"
  }
  tags {
    key   = "sparkcluster-prefix"
    value = var.eks_spark_cluster_prefix
  }
//  allocation_tags  = local.sparkslave_prefix
  provisioner "local-exec" {
    command = "sleep 30"
  }
}

resource "duplocloud_aws_host" "eks-sparklivy" {

  lifecycle {
    create_before_destroy = true
    ignore_changes = [ metadata ]
  }

  user_account = local.tenant_name
  tenant_id    = local.tenant_id

  friendly_name  = local.sparklivy_prefix

  image_id       = var.eks_node_image_name
  capacity       = var.eks_node_instance_type
  agent_platform = 7
  minion_tags {
    key   = "AllocationTags"
    value = local.sparklivy_prefix
  }
  tags {
    key   = "spark"
    value = "livy"
  }
  tags {
    key   = "sparkcluster-prefix"
    value = var.eks_spark_cluster_prefix
  }
  //  allocation_tags  = local.sparkslave_prefix
  provisioner "local-exec" {
    command = "sleep 30"
  }
}

resource "duplocloud_duplo_service" "eks-sparkmaster" {
  depends_on = [duplocloud_aws_host.eks-sparkmaster, duplocloud_aws_host.eks-sparkslave, duplocloud_aws_host.eks-sparklivy]

  lifecycle {
    ignore_changes = [ docker_image ]
  }

  tenant_id = local.tenant_id

  name           = local.sparkmaster_prefix
  agent_platform = 7

  docker_image   = var.spark_master_docker_image
  replicas = 1
  allocation_tags = local.sparkmaster_prefix

  other_docker_config = jsonencode({
    HostNetwork = true,
    Env = [
      { Name = "DUPLO_SPARK_MASTER_IP", Value = "0.0.0.0" },
      { Name = "DUPLO_SPARK_NODE_TYPE", Value = "master" },
    ]
  })
}

resource "duplocloud_duplo_service" "eks-sparkslave" {
  depends_on = [duplocloud_aws_host.eks-sparkmaster, duplocloud_aws_host.eks-sparkslave, duplocloud_aws_host.eks-sparklivy]

  lifecycle {
    ignore_changes = [ docker_image ]
  }

  tenant_id = local.tenant_id
  name  = local.sparkslave_prefix

  agent_platform = 7

  docker_image   = var.spark_slave_docker_image
  replicas = var.eks_spark_cluster_slave_count
  allocation_tags = local.sparkslave_prefix

  other_docker_config = jsonencode({
    HostNetwork = true,
    Env = [
      { Name = "DUPLO_SPARK_MASTER_IP", Value = duplocloud_aws_host.eks-sparkmaster.private_ip_address },
      { Name = "DUPLO_SPARK_NODE_TYPE", Value = "worker" },
    ]
  })

}

resource "duplocloud_duplo_service" "eks-sparklivy" {
  depends_on = [duplocloud_aws_host.eks-sparkmaster, duplocloud_aws_host.eks-sparkslave, duplocloud_aws_host.eks-sparklivy]

  lifecycle {
    ignore_changes = [ docker_image ]
  }

  tenant_id = local.tenant_id
  name  = local.sparklivy_prefix

  agent_platform = 7

  docker_image   = var.spark_livy_docker_image
  replicas = 1
  allocation_tags = local.sparklivy_prefix

  other_docker_config = jsonencode({
    HostNetwork = true,
    Env = [
      { Name = "DUPLO_SPARK_MASTER_IP", Value = duplocloud_aws_host.eks-sparkmaster.private_ip_address },
      { Name = "DUPLO_SPARK_NODE_TYPE", Value = "livy" },
    ]
  })

}



resource "local_file" "eks-sparkmaster-ip" {
  depends_on = [duplocloud_aws_host.eks-sparkmaster, duplocloud_aws_host.eks-sparkslave, duplocloud_aws_host.eks-sparklivy, duplocloud_duplo_service.eks-sparkslave]

  content     = duplocloud_aws_host.eks-sparkmaster.private_ip_address
  filename = "${path.module}/eks-sparkmaster-ip"
}


//resource "local_file" "eks-sparkslave-ip" {
//  depends_on = [duplocloud_aws_host.eks-sparkmaster, duplocloud_aws_host.eks-sparkslave, duplocloud_aws_host.eks-sparklivy, duplocloud_duplo_service.eks-sparkslave]
////  count = var.eks_spark_cluster_slave_count
//
//
//  content     = join(separator, duplocloud_aws_host.eks-sparkslave.private_ip_address)
//  filename = "${path.module}/eks-sparkslave-ip"
//}
resource "local_file" "eks-sparklivy-ip" {
  depends_on = [duplocloud_aws_host.eks-sparkmaster, duplocloud_aws_host.eks-sparkslave, duplocloud_aws_host.eks-sparklivy, duplocloud_duplo_service.eks-sparkslave]

  content     = duplocloud_aws_host.eks-sparklivy.private_ip_address
  filename = "${path.module}/eks-sparklivy-ip"
}