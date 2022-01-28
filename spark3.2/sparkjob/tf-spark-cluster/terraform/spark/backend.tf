terraform {
  backend "s3" {
    workspace_key_prefix = "tenant:"
    region               = "us-west-2"
    key                  = var.eks_spark_cluster_prefix
    encrypt              = true
  }
}
