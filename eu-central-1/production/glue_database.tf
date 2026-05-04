resource "aws_glue_catalog_database" "veld-vine-db" {
  name = "veld_vine"

  tags = local.common_tags
}
