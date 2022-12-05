
terraform {
  required_providers {
    duplocloud = {
      version = "= 0.7.14"
      source = "duplocloud/duplocloud"
    }
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
  region =  data.duplocloud_tenant_aws_region.this.aws_region
  availability_domain = var.availability_domain
#  zone_count = 2

  config_s3_bucket = "duploservices-${local.tenant_name}-config-${local.account_id}"
  env_name = coalesce(var.tenant_name, local.tenant_name)

  sparkmaster_prefix = "${var.oci_spark_cluster_prefix}-sparkmaster"
  ocikey_prefix = "${var.oci_spark_cluster_prefix}-oci"
#  sparkmaster_full_name = "duploservices-${local.tenant_name}-${var.oci_spark_cluster_prefix}-sparkmaster"
  sparkslave_prefix = "${var.oci_spark_cluster_prefix}-sparkslave"
  sparknotebook_prefix = "${var.oci_spark_cluster_prefix}-sparknotebook"

  notebook_memory_in_gbs_resource_request= "${var.notebook_node_memory_in_gbs  - 4}Gi"
  notebook_memory_in_gbs_resource_limit="${var.notebook_node_memory_in_gbs - 4}Gi"
  notebook_ocpus_resource_request= "${var.notebook_node_ocpus * 1000 - 2000}m"
  notebook_ocpus_resource_limit= "${var.notebook_node_ocpus  * 1000 - 2000}m"


  slave_memory_in_gbs_resource_request= "${var.slave_node_memory_in_gbs  - 4}Gi"
  slave_memory_in_gbs_resource_limit="${var.slave_node_memory_in_gbs - 4}Gi"
  slave_ocpus_resource_request= "${var.slave_node_ocpus * 1000 - 1500}m"
  slave_ocpus_resource_limit= "${var.slave_node_ocpus * 1000 - 1500}m"

  master_memory_in_gbs_resource_request= "${var.master_node_memory_in_gbs  - 4}Gi"
  master_memory_in_gbs_resource_limit="${var.master_node_memory_in_gbs - 4}Gi"
  master_ocpus_resource_request= "${var.master_node_ocpus * 1000 - 2000}m"
  master_ocpus_resource_limit= "${var.master_node_ocpus * 1000 - 2000}m"


  node_k8autoscaler_prefix          = "${var.oci_spark_cluster_prefix}-sparknotebook"
  service_k8autoscaler_name         = "${var.oci_spark_cluster_prefix}-k8autoscaler-svc"
  service_k8autoscaler_docker_image = "duplocloud/anyservice:ocik8autoscaler-1.21.1-3_v1"
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

 

resource "duplocloud_oci_containerengine_node_pool" "oci-sparkmaster" {


  name          = local.sparkmaster_prefix
  tenant_id     = local.tenant_id
  node_image_id = var.node_image_id
  node_shape    = var.master_node_instance_type

  node_shape_config {
  memory_in_gbs=var.master_node_memory_in_gbs
  ocpus=var.master_node_ocpus
  }

  node_config_details {
  size = 1

    placement_configs {
      availability_domain = local.availability_domain
      subnet_id           = var.subnetid
    }

    freeform_tags = {
      CreatedBy = "duplo"
      Spark = "master"
    }
  }

  initial_node_labels {
    key   = "allocationtags"
    value = local.sparkmaster_prefix
  }

  lifecycle {
     create_before_destroy = true
     ignore_changes = [
      node_config_details.0.freeform_tags,
      defined_tags
    ]
  }

   provisioner "local-exec" {
    command = "sleep 120"
  }

}


resource "duplocloud_oci_containerengine_node_pool" "oci-sparkslave" {

  name          = local.sparkslave_prefix
  tenant_id     = local.tenant_id
  node_image_id = var.node_image_id
  node_shape    = var.slave_node_instance_type


  node_shape_config {
    memory_in_gbs=var.slave_node_memory_in_gbs
    ocpus=var.slave_node_ocpus
    }

  node_config_details {
    size = var.oci_spark_cluster_slave_count
    placement_configs {
      availability_domain = local.availability_domain
      subnet_id           = var.subnetid
    }


    freeform_tags = {
      CreatedBy = "duplo"
      Spark = "slave"
    }
  }

  initial_node_labels {
    key   = "allocationtags"
    value = local.sparkslave_prefix
  }

  lifecycle {
     create_before_destroy = true
     ignore_changes = [
      node_config_details.0.freeform_tags,
      defined_tags
    ]
  }

   provisioner "local-exec" {
    command = "sleep 120"
  }

}



resource "duplocloud_oci_containerengine_node_pool" "oci-sparknotebook" {

  name          = local.sparknotebook_prefix
  tenant_id     = local.tenant_id
  node_image_id = var.node_image_id
  node_shape    = var.notebook_node_instance_type

    node_shape_config {
    memory_in_gbs=var.notebook_node_memory_in_gbs
    ocpus=var.notebook_node_ocpus
    }

  node_config_details {
    size = var.oci_spark_notebook_count
  #memory_in_gbs (Number)
  #ocpus (Number)

    placement_configs {
      availability_domain = local.availability_domain
      subnet_id           = var.subnetid
    }

    freeform_tags = {
      CreatedBy = "duplo"
      Spark = "notebook"
    }
  }

  initial_node_labels {
    key   = "allocationtags"
    value = local.sparknotebook_prefix
  }

  lifecycle {
     create_before_destroy = true
     ignore_changes = [
      node_config_details.0.freeform_tags,
      defined_tags
    ]
  }

   provisioner "local-exec" {
    command = "sleep 120"
  }

}


resource "duplocloud_duplo_service" "oci-sparkmaster" {
  depends_on = [duplocloud_oci_containerengine_node_pool.oci-sparkmaster,
       duplocloud_oci_containerengine_node_pool.oci-sparkslave]


  lifecycle {
    ignore_changes = [ docker_image ]
  }

  tenant_id = local.tenant_id

  name           = local.sparkmaster_prefix
  agent_platform = 7
  cloud = 1

  docker_image   = var.spark_master_docker_image
  replicas = 1
  allocation_tags = local.sparkmaster_prefix

#  volumes = jsonencode(
#    [
#     {
#      Name: "data-storage",
#      Path : "/data",
#      Spec : {
#        HostPath: {
#          Path: "/data"
#          }
#        }
#      },
#      {
#      Name: "tmp-storage",
#      Path : "/tmp3",
#      Spec : {
#        EmptyDir: {}
#        }
#      }
#    ]
#  )


  other_docker_config = jsonencode({
    HostNetwork = true,
    Env = [
      { Name = "DUPLO_SPARK_MASTER_IP", Value = "0.0.0.0" },
      { Name = "DUPLO_SPARK_NODE_TYPE", Value = "master" },
      { Name = "OKE_USE_INSTANCE_PRINCIPAL", Value = "true" },
      { Name = "OCI_CLI_AUTH", Value = var.oci_instance_principal },
    ],
    "resources": {
      "requests": {
        "memory": local.master_memory_in_gbs_resource_request,
        "cpu": local.master_ocpus_resource_request
      },
      "limits": {
        "memory": local.master_memory_in_gbs_resource_limit,
        "cpu": local.master_ocpus_resource_request
      }
    }
  })
}

resource "duplocloud_duplo_service" "oci-sparkslave" {
 depends_on = [duplocloud_oci_containerengine_node_pool.oci-sparkmaster,
       duplocloud_oci_containerengine_node_pool.oci-sparkslave]

  lifecycle {
    ignore_changes = [ docker_image ]
  }

  tenant_id = local.tenant_id
  name  = local.sparkslave_prefix

  agent_platform = 7
  cloud = 1

  docker_image   = var.spark_slave_docker_image
  replicas = var.oci_spark_cluster_slave_count
  allocation_tags = local.sparkslave_prefix

  hpa_specs = jsonencode(
      {
        "maxReplicas": "${var.oci_spark_cluster_slave_count + 10}",
        "metrics": [
          {
            "resource": {
              "name": "cpu",
              "target": {
                "averageUtilization": 80,
                "type": "Utilization"
              }
            },
            "type": "Resource"
          }
        ],
        "minReplicas": var.oci_spark_cluster_slave_count
      }
    )
#maxReplicas: 5
#metrics:
#  - resource:
#      name: cpu
#      target:
#        averageUtilization: 80
#        type: Utilization
#    type: Resource
#minReplicas: 2
#   volumes = jsonencode(
#   [
#     {
#      Name: "data-storage",
#      Path : "/data",
#      Spec : {
#        HostPath: {
#          Path: "/data"
#          }
#        }
#      },
#      {
#      Name: "tmp-storage",
#      Path : "/tmp3",
#      Spec : {
#        EmptyDir: {}
#        }
#      }
#    ]
#  )

  other_docker_config = jsonencode({
    HostNetwork = true,
    Env = [
      { Name = "DUPLO_SPARK_MASTER_IP", Value = duplocloud_oci_containerengine_node_pool.oci-sparkmaster.nodes[0].private_ip },
      { Name = "DUPLO_SPARK_NODE_TYPE", Value = "worker" },
      { Name = "OKE_USE_INSTANCE_PRINCIPAL", Value = "true" },
      { Name = "OCI_CLI_AUTH", Value = var.oci_instance_principal },

    ],
    "resources": {
      "requests": {
        "memory": local.slave_memory_in_gbs_resource_request,
        "cpu": local.slave_ocpus_resource_request
      },
      "limits": {
        "memory": local.slave_memory_in_gbs_resource_limit,
        "cpu": local.slave_ocpus_resource_limit
      }
    }
  })

}

resource "duplocloud_duplo_service" "oci-sparknotebook" {
 depends_on = [duplocloud_oci_containerengine_node_pool.oci-sparkmaster,
        duplocloud_oci_containerengine_node_pool.oci-sparkslave,
        duplocloud_oci_containerengine_node_pool.oci-sparknotebook]

  lifecycle {
    ignore_changes = [ docker_image ]
  }

  tenant_id = local.tenant_id
  name  = local.sparknotebook_prefix

  agent_platform = 7
  cloud = 1

  docker_image   = var.spark_notebook_docker_image
  replicas = var.oci_spark_notebook_count
  allocation_tags = local.sparknotebook_prefix

#   volumes = jsonencode(
#     [
#     {
#      Name: "data-storage",
#      Path : "/data",
#      Spec : {
#        HostPath: {
#          Path: "/data"
#          }
#        }
#      },
#      {
#      Name: "tmp-storage",
#      Path : "/tmp3",
#      Spec : {
#        EmptyDir: {}
#        }
#      }
#    ]
#  )

  other_docker_config = jsonencode({
    HostNetwork = true,
    Env = [
      { Name = "DUPLO_SPARK_MASTER_IP", Value = duplocloud_oci_containerengine_node_pool.oci-sparkmaster.nodes[0].private_ip },
      { Name = "DUPLO_SPARK_NODE_TYPE", Value = "notebook" },
      { Name = "OKE_USE_INSTANCE_PRINCIPAL", Value = "true" },
      { Name = "OCI_CLI_AUTH", Value = var.oci_instance_principal },
    ],
    "resources": {
      "requests": {
        "memory": local.notebook_memory_in_gbs_resource_request,
        "cpu": local.notebook_ocpus_resource_request
      },
      "limits": {
        "memory": local.notebook_memory_in_gbs_resource_limit,
        "cpu": local.notebook_ocpus_resource_limit
      }
    }
  })

}

resource "duplocloud_duplo_service" "oci-k8autoscaler" {
  depends_on = [
    duplocloud_oci_containerengine_node_pool.oci-sparkmaster,
    duplocloud_oci_containerengine_node_pool.oci-sparkslave,
    duplocloud_oci_containerengine_node_pool.oci-sparknotebook
  ]

  lifecycle {
    ignore_changes = [docker_image]
  }

  tenant_id = local.tenant_id
  name      = local.service_k8autoscaler_name

  agent_platform = 7
  cloud          = 1

  docker_image    = local.service_k8autoscaler_docker_image
  replicas        = 1
  allocation_tags = local.sparknotebook_prefix

  #  volumes = jsonencode(
  #    [
  #     {
  #      Name: "data-storage",
  #      Path : "/data",
  #      Spec : {
  #        HostPath: {
  #          Path: "/data"
  #          }
  #        }
  #      },
  #      {
  #      Name: "tmp-storage",
  #      Path : "/tmp3",
  #      Spec : {
  #        EmptyDir: {}
  #        }
  #      }
  #    ]
  #  )

  other_docker_config = jsonencode({
    HostNetwork = true,
    Env         = [
      { Name  = "DUPLO_SPARK_MASTER_IP",
        Value = duplocloud_oci_containerengine_node_pool.oci-sparkmaster.nodes[0].private_ip
      },
      { Name  = "DUPLO_SLAVE_NODE_POOLID",
        Value = duplocloud_oci_containerengine_node_pool.oci-sparkslave.node_pool_id
      },
      { Name  = "OCI_SLAVE_NODE_SCALE_MIN",
        Value = "${var.oci_spark_cluster_slave_count - 0}"
      },
      { Name  = "OCI_SLAVE_NODE_SCALE_MAX",
        Value = "${var.oci_spark_cluster_slave_count + 10}"
      },
      { Name  = "OCI_SLAVE_NODE_SCALE_REGION",
        Value = "us-ashburn-1"
      },
      { Name = "DUPLO_SPARK_NODE_TYPE", Value = "k8autoscaler" },
      { Name = "OKE_USE_INSTANCE_PRINCIPAL", Value = "true" },
      { Name = "OCI_CLI_AUTH", Value = var.oci_instance_principal },
    ],
    "resources" : {
      "requests" : {
         "cpu": "100m",
        "memory" : "400Mi"
      },
      "limits" : {
        "cpu": "500m",
        "memory" : "600Mi"
      }
    }
  })
}

resource "local_file" "oci-sparkmaster-ip" {
  depends_on = [duplocloud_oci_containerengine_node_pool.oci-sparkmaster]

  content  =   duplocloud_oci_containerengine_node_pool.oci-sparkmaster.nodes[0].private_ip

  filename = "${path.module}/../../../build/oci-sparkmaster-ip"
}

resource "local_file" "oci-sparknotebook-ip" {
  depends_on = [duplocloud_oci_containerengine_node_pool.oci-sparknotebook]

  content  =   duplocloud_oci_containerengine_node_pool.oci-sparknotebook.nodes[0].private_ip

  filename = "${path.module}/../../../build/oci-sparknotebook-ip"
}
