resource "aws_s3_bucket" "federated-engineers-bucket" {
  bucket        = "federated-engineers-${var.environment}-${var.team}-${var.bucket-use-case}"
  force_destroy = true

  tags = merge(local.common_tags, {
    Name    = "federated-engineers-${var.environment}-${var.team}-${var.bucket-use-case}",
    Service = var.service
  })
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.federated-engineers-bucket.id

  versioning_configuration {
    status = var.versioning
  }
}
