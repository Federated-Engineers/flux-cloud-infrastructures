module "nordic_s3_bucket" {
  source = "../modules/s3-bucket"
  
  team = var.team
  environment = var.environment
  bucket-use-case = "data-lake"
  service = "airflow"
  versioning = "Enabled"

}