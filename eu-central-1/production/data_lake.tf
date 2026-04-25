module "nordic_s3_bucket" {
  source = "../modules/s3-bucket"
  team            = var.team
  environment     = var.environment
  bucket-use-case = "nordic"
  service         = "flux-airflow"
  versioning      = "Enabled"
}

module "riveira_bucket" {
  source          = "../modules/s3-bucket"
  bucket-use-case = "riveira-dataset"
  versioning      = "Enabled"
  team            = "flux"
  environment     = "production"
  service         = "data-lake"
}
