module "atlantis_test" {
  source          = "../modules/s3-bucket"
  team            = "flux"
  bucket-use-case = "data-lake"
  service         = "atlantis-test"
  versioning      = "Enabled"
  environment     = var.environment
}