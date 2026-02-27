resource "aws_s3_bucket" "federated_flux_staging_bucket" {
  bucket = "federated-flux-staging-bucket"
  tags = merge(local.common_tags, {
    Name = "flux_staging_bucket"
    }
  )
}

resource "aws_s3_bucket" "federated_flux_atlantis_test_bucket" {
  bucket = "federated-flux-atlantis_test-bucket"
  tags = merge(local.common_tags, {
    Name = "flux_atlantis_test_bucket"
    }
  )
}