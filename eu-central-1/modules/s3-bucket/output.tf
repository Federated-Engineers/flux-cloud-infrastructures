output "bucket_name" {
  value = aws_s3_bucket.federated-engineers-bucket.bucket
}

output "arn" {
  description = "ARN of the bucket"
  value       = aws_s3_bucket.federated-engineers-bucket.arn
}