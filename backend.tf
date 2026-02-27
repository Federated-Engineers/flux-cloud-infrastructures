terraform {
  backend "s3" {
    bucket = "federated-flux-staging-bucket"
    key    = "statefile/"
    region = "eu-central-1"
  }
}
