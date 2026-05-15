# # Create a new endpoint
# resource "aws_dms_endpoint" "postgres_endpoint" {
#   database_name               = "postgres"
#   endpoint_id                 = "postgres-database-endpoint"
#   endpoint_type               = "source"
#   engine_name                 = "postgres"
#   password                    = aws_ssm_parameter.database_password.value
#   port                        = 5432
#   server_name                 = aws_db_instance.vitava_transact_db.address
#   ssl_mode                    = "none"
#   postgres_settings           {
#     authentication_method = "password"
#     capture_ddls          = true
#     heartbeat_enable      = true
#     execute_timeout       = 3600
#   }



#   tags = local.common_tags

#   username = "flux_admin"
# }

# resource "aws_dms_s3_endpoint" "vitava_cdc_lake_endpoint" {
#   endpoint_id   = "vitava-bucket"
#   endpoint_type = "target"

#   tags = local.common_tags

#   add_column_name                             = true
#   bucket_name                                 = module.vitava_bucket.bucket_name
#   dict_page_size_limit                        = 1000000
#   data_format                                 = "parquet"
#   data_page_size                              = 1100000
#   date_partition_delimiter                    = "UNDERSCORE"
#   date_partition_enabled                      = true
#   date_partition_sequence                     = "yyyymmdd"
#   enable_statistics                           = false
#   encoding_type                               = "plain"
#   parquet_version                             = "parquet-2-0"
#   parquet_timestamp_in_millisecond            = true
#   service_access_role_arn                     = aws_iam_role.vitava_dms_role.arn
#   timestamp_column_name                       = "cdc_timestamp"
#   glue_catalog_generation                     = true

# }

# resource "aws_dms_s3_endpoint" "vitava_full_load_lake_endpoint" {
#   endpoint_id   = "vitavafull-bucket"
#   endpoint_type = "target"

#   tags = local.common_tags

#   bucket_name                                 = module.vitava_bucket.bucket_name
#   cdc_inserts_and_updates                     = true
#   dict_page_size_limit                        = 1000000
#   data_format                                 = "parquet"
#   data_page_size                              = 1100000
#   enable_statistics                           = false
#   encoding_type                               = "plain"
#   parquet_version                             = "parquet-2-0"
#   parquet_timestamp_in_millisecond            = true
#   service_access_role_arn                     = aws_iam_role.vitava_dms_role.arn
#   glue_catalog_generation                     = true

# }

# resource "aws_ssm_parameter" "vitava_s3_dms_endpoint" {
#   name  = "/${var.environment}/${var.team}/s3-dms-endpoint"
#   type  = "String"
#   value = aws_dms_s3_endpoint.vitava_cdc_lake_endpoint.endpoint_arn

#   tags = local.common_tags
# }


# resource "aws_ssm_parameter" "vitava_rds_dms_endpoint" {
#   name  = "/${var.environment}/${var.team}/rds-dms-endpoint"
#   type  = "String"
#   value = aws_dms_endpoint.postgres_endpoint.endpoint_arn

#   tags = local.common_tags
# }

# resource "aws_iam_role" "vitava_dms_role" {
#   name = "vitava_dms_role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Sid    = "AllowDMSAssumeRole"
#         Principal = {
#           Service = "dms.amazonaws.com"
#         }
#       },
#     ]
#   })
# }

# resource "aws_iam_policy" "vitava_dms_policy" {
#   name        = "flux_vitava_dms_policy"
#   description = "vitava client project with dms access to s3 policy"


#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = [
#           "s3:GetBucketLocation", 
#           "s3:GetObject",
#           "s3:ListBucket", 
#           "s3:ListBucketMultipartUploads", 
#           "s3:ListMultipartUploadParts", 
#           "s3:AbortMultipartUpload",
#           "s3:DeleteObject",
#           "s3:DeleteObjectVersion",
#           "s3:PutObject",
#           "s3:PutObjectTagging",
#           "s3:PutObjectAcl",
#           "s3:DeleteObjectTagging",
#           "s3:DeleteObjectVersionTagging"
#         ],
#         Effect = "Allow"
#         Resource = [
#           "arn:aws:s3:::federated-engineers-production-flux-data-engineers-vitava",
#           "arn:aws:s3:::federated-engineers-production-flux-data-engineers-vitava/*",
#         ]
#       },
#       {
#         Effect = "Allow", 
#         Action = [ 
#                 "glue:CreateDatabase", 
#                 "glue:GetDatabase", 
#                 "glue:CreateTable", 
#                 "glue:DeleteTable", 
#                 "glue:UpdateTable", 
#                 "glue:GetTable", 
#                 "glue:BatchCreatePartition", 
#                 "glue:CreatePartition", 
#                 "glue:UpdatePartition", 
#                 "glue:GetPartition", 
#                 "glue:GetPartitions", 
#                 "glue:BatchGetPartition"
#         ], 
#         Resource = [
#             "arn:aws:glue:*:${var.accnt_num}:catalog", 
#             "arn:aws:glue:*:${var.accnt_num}:database/*", 
#             "arn:aws:glue:*:${var.accnt_num}:table/*" 
#         ]
#       }, 
#       {
#         Effect = "Allow",
#         Action = [
#             "athena:StartQueryExecution",
#             "athena:GetQueryExecution", 
#             "athena:CreateWorkGroup"
#         ],
#         Resource = "arn:aws:athena:*:${var.accnt_num}:workgroup/glue_catalog_generation_for_task_*"
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "vitava-policy-attachment" {
#   role       = aws_iam_role.vitava_dms_role.name
#   policy_arn = aws_iam_policy.vitava_dms_policy.arn
# }

# data "aws_iam_role" "dms-vpc-role" {
#   name = "dms-vpc-role"
    
# }

# data "aws_iam_role" "dms-cloudwatch-logs-role" {
#   name = "dms-cloudwatch-logs-role"
    
# }

# resource "aws_iam_role_policy_attachment" "vitava_sg_policy" {
#   role       = data.aws_iam_role.dms-vpc-role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
# }

# # Attach the managed policy required for DMS logging
# resource "aws_iam_role_policy_attachment" "dms_cloudwatch_attachment" {
#   role       = data.aws_iam_role.dms-cloudwatch-logs-role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSCloudWatchLogsRole"
# }

# # resource "aws_dms_replication_config" "serverless_rds_to_s3" {
# #   replication_config_identifier = "vitava-replication"
# #   resource_identifier           = "vitava-replication"
# #   replication_type              = "full-load-and-cdc"
# #   source_endpoint_arn           = aws_dms_endpoint.postgres_endpoint.endpoint_arn
# #   target_endpoint_arn           = aws_dms_s3_endpoint.vitava_cdc_lake_endpoint.endpoint_arn
# #   table_mappings                = <<EOF
# #   {
# #     "rules": [
# #           {
# #               "rule-type": "selection",
# #               "rule-id": "1",
# #               "rule-name": "1",
# #               "object-locator": {
# #                   "schema-name": "public",
# #                   "table-name": "%"
# #               },
# #               "rule-action": "include"
# #           }
# #       ]
    
# #   }
# # EOF

# #   start_replication = true
# #   replication_settings = jsonencode(jsondecode(file("${path.module}/config/task_settings.json")))
  
  

# #   compute_config {
# #     replication_subnet_group_id  = aws_dms_replication_subnet_group.vitava_replication_subnet_group.replication_subnet_group_id
# #     max_capacity_units           = 2
# #     min_capacity_units           = 1
# #     preferred_maintenance_window = "sun:23:45-mon:00:30"
# #     vpc_security_group_ids       = [data.aws_security_group.selected.id]
# #   }
# # }

# # resource "aws_ssm_parameter" "vitava_dms_replication_config" {
# #   name  = "/${var.environment}/${var.team}/dms-replication-config-arn"
# #   type  = "String"
# #   value = aws_dms_replication_config.serverless_rds_to_s3.arn

# #   tags = local.common_tags
# # }


# # resource "aws_dms_replication_subnet_group" "vitava_replication_subnet_group" {
# #   replication_subnet_group_description = "vitava_replication_sg"
# #   replication_subnet_group_id          = "vitava-sg"

# #   subnet_ids = tolist(data.aws_subnets.private.ids)
    

# #   tags = local.common_tags

# #   # explicit depends_on is needed since this resource doesn't reference the role or policy attachment
# #   depends_on = [aws_iam_role_policy_attachment.vitava_sg_policy]
# # }

