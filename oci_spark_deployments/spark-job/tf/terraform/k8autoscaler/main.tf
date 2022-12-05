terraform {
  required_providers {
    duplocloud = {
      version = "~> 0.7.9"
      source  = "duplocloud/duplocloud"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

provider "duplocloud" {}

locals {
  tenant_name = var.tenant_name
  tenant_id   = data.duplocloud_tenant.this.id

  account_id          = data.duplocloud_aws_account.this.account_id
  region              = data.duplocloud_tenant_aws_region.this.aws_region
  availability_domain = var.availability_domain

  config_s3_bucket = "duploservices-${local.tenant_name}-config-${local.account_id}"
  env_name         = coalesce(var.tenant_name, local.tenant_name)
 
  # diagnostics
  node_diagnostics_prefix     = "${var.oci_k8_auto_scaler_prefix}-diagnostics"
  service_es_name             = "${var.oci_k8_auto_scaler_prefix}-es-svc"
  service_es_docker_image     = "duplocloud/opensearch:1.2.0-r1"
  service_kibana_name         = "${var.oci_k8_auto_scaler_prefix}-kibana-svc"
  service_kibana_docker_image = "duplocloud/opensearch-dashboards:1.2.0-r3"

  # monitoring
  node_monitoring_prefix          = "${var.oci_k8_auto_scaler_prefix}-monitoring"
  service_prometheus_name         = "${var.oci_k8_auto_scaler_prefix}-prometheus-svc"
  service_prometheus_docker_image = "duplocloud/anyservice:ociprometheus_v1"
  service_grafana_name            = "${var.oci_k8_auto_scaler_prefix}-grafana-svc"
  service_grafana_docker_image    = "duplocloud/grafana-dashboard:511d9e9cc9a5c80bfeb6451890cbbd79e4c50abf"

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

resource "duplocloud_oci_containerengine_node_pool" "oci-diagnostics" {
  name          = local.node_diagnostics_prefix
  tenant_id     = local.tenant_id
  node_image_id = var.node_image_id
  node_shape    = var.oci_k8_ms_instance_type

  node_shape_config {
    memory_in_gbs = 8
    ocpus         = 2
  }

  node_config_details {
    size = 1
    placement_configs {
      availability_domain = local.availability_domain
      subnet_id           = var.subnetid
    }
    freeform_tags = {
      CreatedBy = "duplo"
      Spark     = "diagnostics"
    }
  }

  initial_node_labels {
    key   = "allocationtags"
    value = local.node_diagnostics_prefix
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [
      node_config_details.0.freeform_tags,
      defined_tags
    ]
  }

  provisioner "local-exec" {
    command = "sleep 120"
  }
}

resource "duplocloud_oci_containerengine_node_pool" "oci-monitoring" {
  name          = local.node_monitoring_prefix
  tenant_id     = local.tenant_id
  node_image_id = var.node_image_id
  node_shape    = var.oci_k8_ms_instance_type

  node_shape_config {
    memory_in_gbs = 32
    ocpus         = 4
  }

  node_config_details {
    size = 2

    placement_configs {
      availability_domain = local.availability_domain
      subnet_id           = var.subnetid
    }

    freeform_tags = {
      CreatedBy = "duplo"
      Spark     = "monitoring"
    }
  }

  initial_node_labels {
    key   = "allocationtags"
    value = local.node_monitoring_prefix
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [
      node_config_details.0.freeform_tags,
      defined_tags
    ]
  }

  provisioner "local-exec" {
    command = "sleep 120"
  }
}


resource "duplocloud_duplo_service" "system-es-svc" {
  depends_on = [
    duplocloud_oci_containerengine_node_pool.oci-diagnostics,
    duplocloud_oci_containerengine_node_pool.oci-monitoring
  ]

  lifecycle {
    ignore_changes = [docker_image]
  }

  tenant_id = local.tenant_id
  name      = local.service_es_name

  agent_platform = 7
  cloud          = 1

  docker_image    = local.service_es_docker_image
  replicas        = 1
  allocation_tags = local.node_diagnostics_prefix

  volumes = jsonencode(
    [
      {
        Name : "data-storage",
        Path : "/usr/share/opensearch/data",
        Spec : {
          HostPath : {
            Path : "/data/es"
          }
        }
      }
    ]
  )

  other_docker_config = jsonencode({
    HostNetwork = true,
    Env         = [
      { Name = "DUPLO_SPARK_NODE_TYPE", Value = "es" },
      { Name = "OCI_CLI_AUTH", Value = var.oci_instance_principal },
    ],
    Labels = { "co.elastic.logs/enabled" = "false"}
  })

}

resource "duplocloud_duplo_service" "system-svc-kibana-oc" {
  depends_on = [
    duplocloud_oci_containerengine_node_pool.oci-diagnostics,
    duplocloud_oci_containerengine_node_pool.oci-monitoring
  ]

  lifecycle {
    ignore_changes = [docker_image]
  }

  tenant_id = local.tenant_id
  name      = local.service_kibana_name

  agent_platform = 7
  cloud          = 1

  docker_image    = local.service_kibana_docker_image
  replicas        = 1
  allocation_tags = local.node_diagnostics_prefix

  other_docker_config = jsonencode({
    HostNetwork = true,
    Env         = [
      { Name = "ELASTICSEARCH_HOSTS", Value = "http://localhost:9200" },
      { Name = "DISABLE_SECURITY_DASHBOARDS_PLUGIN", Value = "true" },
      { Name = "SERVER_BASEPATH", Value = "/proxy/kibana" },
      { Name = "SERVER_REWRITEBASEPATH", Value = "true"},
      { Name = "DUPLO_SPARK_NODE_TYPE", Value = "kibana" },
      { Name = "OCI_CLI_AUTH", Value = var.oci_instance_principal },
    ],
    Labels = { "co.elastic.logs/enabled" = "false"},
  })

}
 
#resource "duplocloud_duplo_service" "system-prometheus-svc" {
#  depends_on = [
#    duplocloud_oci_containerengine_node_pool.oci-diagnostics,
#    duplocloud_oci_containerengine_node_pool.oci-monitoring
#  ]
#
#  lifecycle {
#    ignore_changes = [docker_image]
#  }
#
#  tenant_id = local.tenant_id
#  name      = local.service_prometheus_name
#
#  agent_platform = 7
#  cloud          = 1
#
#  docker_image    = local.service_prometheus_docker_image
#  replicas        = 1
#  allocation_tags = local.node_monitoring_prefix
#
#  other_docker_config = jsonencode({
#    HostNetwork = true,
#    Env         = [
#      { Name = "DUPLO_SPARK_NODE_TYPE", Value = "prometheus" },
#      { Name = "OCI_CLI_AUTH", Value = var.oci_instance_principal },
#    ],
#    Labels = { "co.elastic.logs/enabled" = "false"}
#  })
#
#}

#resource "duplocloud_duplo_service" "system-grafana-svc" {
#  depends_on = [
#    duplocloud_oci_containerengine_node_pool.oci-diagnostics,
#    duplocloud_oci_containerengine_node_pool.oci-monitoring
#  ]
#
#  lifecycle {
#    ignore_changes = [docker_image]
#  }
#
#  tenant_id = local.tenant_id
#  name      = local.service_grafana_name
#
#  agent_platform = 7
#  cloud          = 1
#
#  docker_image    = local.service_grafana_docker_image
#  replicas        = 1
#  allocation_tags = local.node_monitoring_prefix
#
#  volumes = jsonencode(
#    [
#      {
#        Name : "data-storage",
#        Path : "/usr/share/opensearch/data",
#        Spec : {
#          HostPath : {
#            Path : "/data/es"
#          }
#        }
#      }
#    ]
#  )
#  other_docker_config = jsonencode({
#    HostNetwork = true,
#    Env         = [
#      { Name = "PROMETHEOUS_URL", Value = "http://localhost:9090" },
#      { Name = "GRAFANA_DOMAIN", Value = "ia.duplocloud.net" },
#      { Name = "ADMIN_USERNAME", Value = "duplocloud" },
#      { Name = "ADMIN_PASSWORD", Value = "ia@321" },
#      { Name = "DUPLO_SPARK_NODE_TYPE", Value = "grafana" },
#      { Name = "OCI_CLI_AUTH", Value = var.oci_instance_principal },
#    ],
#    Labels = { "co.elastic.logs/enabled" = "false"}
#  })
#
#}



