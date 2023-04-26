terraform {
  backend "s3" {
    region               = "us-west-2"
    key                  = "rds11"
    workspace_key_prefix = "tenant:"
    encrypt              = true
  }
}
