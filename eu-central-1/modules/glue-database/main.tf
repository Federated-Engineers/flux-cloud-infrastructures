resource "aws_glue_catalog_database" "federated_engineers_glue_database" {
  name = "federated-engineers-${var.database-name}"
}