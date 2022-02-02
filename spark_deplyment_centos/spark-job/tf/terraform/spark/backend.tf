terraform {
  backend "s3" {
    workspace_key_prefix = "tenant:"
    region               = "us-west-2"
    key                  = "jobe3"
    encrypt              = true
  }
}
