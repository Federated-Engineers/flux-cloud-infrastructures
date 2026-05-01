module "nordic_s3_bucket" {
  source = "../modules/s3-bucket"

  team            = var.team
  environment     = var.environment
  bucket-use-case = "nordic"
  service         = "flux-airflow"
  versioning      = "Enabled"
}


module "neuralNest_s3_bucket" {
  source = "../modules/s3-bucket"

  team            = "flux"
  environment     = var.environment
  bucket-use-case = "neuralNest"
  service         = "flux-airflow"
  versioning      = "Enabled"
}