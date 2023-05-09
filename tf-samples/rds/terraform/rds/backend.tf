terraform {
  backend "s3" {
    region               = "us-west-2"
    key                  = "rds27"
    workspace_key_prefix = "tenant:"
    encrypt              = true
  }
}
