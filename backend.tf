terraform {
  backend "s3" {
    bucket = "federated-flux-staging-bucket"
    key    = "statefile/"
    region = "us-central-1"
  }
}