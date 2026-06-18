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

module "riviera_bucket" {
  source = "../modules/s3-bucket"

  bucket-use-case = "riviera-dataset"
  versioning      = "Enabled"
  team            = "flux"
  environment     = "production"
  service         = "data-lake"
}


module "lsa-dbt-terraform-state" {
  source = "../modules/s3-bucket"

  bucket-use-case = "lsa-dbt-terraform-state"
  versioning      = "Enabled"
  team            = "flux"
  environment     = "production"
  service         = "terraform-state"
}

