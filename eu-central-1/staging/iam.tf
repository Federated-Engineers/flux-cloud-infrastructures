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

resource "aws_iam_user" "nordic_user" {
  name = "nordic_user"

  tags = local.common_tags
}

# data "aws_ssm_parameter" "nordic_user" {
#   name  = "nordic_user"
#   # type  = "String"
#   # value = aws_iam_user.nordic_user
# }

# data "aws_ssm_parameter" "nordic_user" {
#   name = aws_ssm_parameter.nordic_user.name
# }

resource "aws_ssm_parameter" "nordic_user" {
  name  = "nordic_user"
  type  = "String"
  value = aws_iam_user.nordic_user.name
}



