terraform {
  backend "s3" {
    workspace_key_prefix = "tenant:"
    region               = "us-west-2"
    key                  = "k8_as_bbb"
    encrypt              = true
  }
}
