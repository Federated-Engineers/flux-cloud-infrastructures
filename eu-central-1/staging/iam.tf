resource "aws_iam_user" "federated_flux_staging_user" {
  name = "flux_staging_user"

  tags = local.common_tags
}

resource "aws_iam_access_key" "flux_access_key" {
  user = aws_iam_user.federated_flux_staging_user.name
}

resource "aws_ssm_parameter" "flux_access" {
  name  = "/staging/flux/aws-access-key"
  type  = "String"
  value = aws_iam_access_key.flux_access_key.id
}

resource "aws_ssm_parameter" "flux_access_secret" {
  name  = "/staging/flux/aws-access-secret-key"
  type  = "String"
  value = aws_iam_access_key.flux_access_key.secret
}

resource "aws_iam_user_policy" "flux_staging_user_policy" {
  name = "flux_staging_user_policy"
  user = aws_iam_user.federated_flux_staging_user.name

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::federated_flux_staging_bucket"
      },
    ]
  })
}

resource "aws_iam_role" "lambda_role" {
  name = "alpen-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"

        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "alpenmechanik-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject"
        ]
        Resource = [
          "${data.aws_s3_bucket.csv_bucket.arn}/*"
        ]
      },

      {
        Effect = "Allow"
        Action = [
          "logs:*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "transfer_role" {
  name = "transfer-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "transfer.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "transfer_s3_policy" {
  name = "transfer-s3-policy"
  role = aws_iam_role.transfer_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = [
          data.aws_s3_bucket.csv_bucket.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = [
          "${data.aws_s3_bucket.csv_bucket.arn}/*"
        ]
      }
    ]
  })
}