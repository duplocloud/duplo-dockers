terraform {
  backend "s3" {
    region               = "us-west-2"
    key                  = "rds23"
    workspace_key_prefix = "tenant:"
    encrypt              = true
  }
}
