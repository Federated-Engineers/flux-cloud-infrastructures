
module "riveira_bucket" {
  source          = "../modules/s3-bucket"
  bucket-use-case = "riveira-dataset"
  versioning      = "Enabled"
  team            = "flux"
  environment     = "production"
  service         = "data-lake"
}

module "veldvine-bucket" {
  source = "../modules/s3-bucket"

  environment     = var.environment
  team            = "flux"
  bucket-use-case = "veld-vine"
  versioning      = "Enabled"
  service         = "flux-airflow"
}

module "neuralnest_s3_bucket" {
  source = "../modules/s3-bucket"

  team            = "flux"
  environment     = var.environment
  bucket-use-case = "neuralnest"
  service         = "flux-airflow"
  versioning      = "Enabled"
}
