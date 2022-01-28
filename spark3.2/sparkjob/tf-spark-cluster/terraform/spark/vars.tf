
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
  default = "job1"
}

variable "eks_node_image_name" {
  type  = string
  default = "ami-076cfc980e4382759"
}

variable "spark_master_docker_image" {
  type  = string
  default = "duplocloud/anyservice:spark_3_2_v6"
}

variable "spark_slave_docker_image" {
  type  = string
  default = "duplocloud/anyservice:spark_3_2_v6"
}

variable "eks_node_instance_type" {
  type  = string
  default = "t3.medium"
}
