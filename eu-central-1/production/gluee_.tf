resource "aws_glue_catalog_database" "veld_vine_catalog_database" {
  name        = "veld-vine-catalog-database"
  description = "Gold layer catalog database"
}

resource "aws_glue_catalog_table" "veld_vine_catalog_table" {
  name          = "veld-vine-catalog-table"
  database_name = aws_glue_catalog_database.veld_vine_catalog_database.name
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    EXTERNAL              = "TRUE"
    "parquet.compression" = "SNAPPY"
  }

  storage_descriptor {
    location      = "s3://veld-vine-s3/silver/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      name                  = "vine-veld"
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"

      parameters = {
        "serialization.format" = "1"
      }
    }
  }
}