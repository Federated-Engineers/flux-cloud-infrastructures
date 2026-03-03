terraform {
  backend "s3" {
    bucket = "federated-engineers-terraform-state"
    key    = "production/flux/terraform.tfstate"
    region = "eu-central-1"
  }
}
