module "nordic_s3_bucket" {
  source = "../modules/s3-bucket"

  team            = var.team
  environment     = var.environment
  bucket-use-case = "nordic"
  service         = "flux-airflow"
  versioning      = "Enabled"
}


module "neuralnest_s3_bucket" {
  source = "../modules/s3-bucket"

  team            = "flux"
  environment     = var.environment
  bucket-use-case = "neuralnest"
  service         = "flux-airflow"
  versioning      = "Enabled"
}