module "nordic_s3_bucket" {
  source = "../modules/s3-bucket"

  team            = var.team
  environment     = var.environment
  bucket-use-case = "nordic"
  service         = "flux-airflow"
  versioning      = "Enabled"
}

module "veldvine-bucket" {
  source = "../modules/s3-bucket"

  environment     = var.environment
  team            = "flux"
  bucket-use-case = "veld_vine"
  versioning      = "Enabled"
  service         = "flux-airflow"
}
