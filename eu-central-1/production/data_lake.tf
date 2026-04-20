module "riveira_bucket" {
  source          = "../modules/s3-bucket"
  bucket-use-case = "riveira-dataset"
  versioning      = "Enabled"
  team            = "flux"
  environment = "production"
  service         = "data-lake"
}

