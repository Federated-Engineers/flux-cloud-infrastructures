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
          module.riviera_bucket.arn,
          "${module.riviera_bucket.arn}/*",
          module.alpenmechanik-bucket.arn
        ]
      },
      {
        Sid    = "ReadSSMParameters"
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ]
        Resource = [
          "arn:aws:ssm:eu-central-1:049417293525:parameter/production/google-service-account/credentials",
        ]
      },

      {
        Sid    = "GlueActions"
        Effect = "Allow"
        Action = [
          "glue:*"
        ]
        Resource = ["*"]
      }
    ]
  })
}
