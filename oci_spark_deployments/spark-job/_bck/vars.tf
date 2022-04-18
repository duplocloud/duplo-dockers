/*
// commented code

variable "oci_spark_cluster_prefix" {
  type  = string
  default = "ocij7"
}

variable "tenant_name" {
    type = string
    default =   "ocispark"
}

variable "availability_domain" {
    type = string
    default =   "uwFr:AP-MUMBAI-1-AD-1"
}

variable "subnetid" {
    type = string
    default =   "ocid1.subnet.oc1.ap-mumbai-1.aaaaaaaasz36nwww2zygjn7arpuq4fbz3z22kn6adlalldvld3b5nu6afuxa"
}

variable "node_image_id" {
  type  = string
  default = "ocid1.image.oc1.ap-mumbai-1.aaaaaaaagosxifkwha6a6pi2fxx4idf3te3icdsf7z6jar2sxls6xycnehna"
}

variable "spark_master_docker_image" {
  type  = string
  default = "duplocloud/anyservice:spark_3_2_ia_v1"
}

variable "spark_slave_docker_image" {
  type  = string
  default = "duplocloud/anyservice:spark_3_2_ia_v1"
}

variable "spark_livy_docker_image" {
  type  = string
  default = "duplocloud/anyservice:spark_3_2_ia_livy_v1"
}

variable "master_node_instance_type" {
  type  = string
  default = "VM.Standard2.1"
}

variable "slave_node_instance_type" {
  type  = string
#  default = "VM.Standard2.8"
  default = "VM.Standard2.1"
}

variable "livy_node_instance_type" {
  type  = string
#  default = "VM.Standard2.4"
  default = "VM.Standard2.1"
}


variable "oci_spark_cluster_slave_count" {
  type  = number
  default = 3
}


*/