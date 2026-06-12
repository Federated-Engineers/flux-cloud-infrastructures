resource "aws_glue_catalog_database" "rivieraglue" {
  name = "riviera_glue_database"

  tags = local.common_tags
}