
variable "env_names" {
    type = map(string)
    default = {
        "sparkdemo" = "sparkdemo"
    }
}

variable "eks_spark_cluster_slave_count" {
  type  = number
  default = 4
}

variable "eks_spark_cluster_prefix" {
  type  = string
  default = "job2"
}

variable "eks_node_image_name" {
  type  = string
  default = "ami-0cdd9b2ea797fd5db"
}

variable "spark_master_docker_image" {
  type  = string
  default = "duplocloud/anyservice:spark_3_2_centos_v1"
}


variable "spark_slave_docker_image" {
  type  = string
  default = "duplocloud/anyservice:spark_3_2_centos_v1"
}

variable "spark_livy_docker_image" {
  type  = string
  default = "duplocloud/anyservice:spark_3_2_centos_livy_v1"
}
variable "eks_node_instance_type" {
  type  = string
  default = "t3.medium"
}
