# resource "aws_s3_bucket" "federated_flux_staging_bucket" {
#   bucket = "federated-flux-staging-bucket"
#     tags = merge(local.common_tags, {
#       Name        = "flux_staging_bucket"
#     }
# )
# }