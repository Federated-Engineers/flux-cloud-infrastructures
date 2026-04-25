module "nordic_s3_bucket" {
  source = "../modules/s3-bucket"

  team            = var.team
  environment     = var.environment
  bucket-use-case = "nordic"
  service         = "flux-airflow"
  versioning      = "Enabled"
}

module "vitava_bucket" {
  source          = "../modules/s3-bucket"
  bucket-use-case = "vitava"
  versioning      = "Disabled"
  team            = var.team
  environment     = var.environment
  service         = "data-lake"
}
