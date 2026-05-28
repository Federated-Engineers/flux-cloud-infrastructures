module "vine_veld_s3_bucket" {
  source = "../modules/s3-bucket"

  team            = var.team
  environment     = var.environment
  bucket-use-case = "vine-veld"
  service         = "flux-airflow"
  versioning      = "Enabled"
}

locals {
  medallion = [
    "bronze/vineyard_harvest/",
    "bronze/export_consignment/",
    "silver/vineyard_harvest/",
    "silver/export_consignment/",
    "gold/vineyard_harvest/",
    "gold/export_consignment/"
  ]
}

resource "aws_s3_object" "medallion" {
  for_each = toset(local.medallion)

  bucket = module.vine_veld_s3_bucket.bucket_name
  key    = each.value
}
