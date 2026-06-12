resource "aws_glue_catalog_database" "veld-vine-db" {
  name = "prod_veld_vine"

  tags = local.common_tags
}

resource "aws_glue_catalog_database" "rivieraglue" {
  name = "riviera_glue_database"

  tags = local.common_tags
}
