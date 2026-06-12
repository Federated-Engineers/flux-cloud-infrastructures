resource "aws_iam_policy" "airflow_policy" {
  name        = "flux-airflow-access-policy"
  description = "Allow Airflow to access aws resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:List*",
          "s3:*Object*"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::federated-flux-staging-bucket",
          "arn:aws:s3:::federated-flux-staging-bucket/*",
          module.nordic_s3_bucket.arn,
          "${module.nordic_s3_bucket.arn}/*",
          "arn:aws:s3:::nrc-logistics-raw",
          "arn:aws:s3:::nrc-logistics-raw/*",
          module.riveira_bucket.arn,
          "${module.riveira_bucket.arn}/*",
        ]
      },
    ]
  })
}
