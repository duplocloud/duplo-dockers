terraform {
  backend "s3" {
    region               = "us-west-2"
    key                  = "rds"
    workspace_key_prefix = "tenant:"
    encrypt              = true
  }
}
