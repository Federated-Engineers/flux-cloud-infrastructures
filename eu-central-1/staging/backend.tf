terraform {
  backend "s3" {
    bucket = "federated-engineers-terraform-state"
    key    = "staging/flux/terraform.tfstate"
    region = "eu-central-1"
  }
}

terraform {
  backend "s3" {
    bucket         = "alpenmechanik-datalake"
    key            = "production/terraform.tfstate"
    region         = "eu-central-1"
    encrypt        = true
  }
}