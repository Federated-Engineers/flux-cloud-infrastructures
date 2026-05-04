resource "aws_glue_catalog_database" "veld-vine-db" {
  name = "veldvineDatabase"

  tags = local.common_tags
}
