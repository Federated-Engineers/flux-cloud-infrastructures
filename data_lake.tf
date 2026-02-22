resource "aws_s3_bucket" "federated_flux_demo" {
  bucket = "federated-engineers-flux-test-bucket1"
}

resource "aws_s3_bucket" "federated_flux_demo1" {
  bucket = "federated-engineers-flux-test-bucket2"
}