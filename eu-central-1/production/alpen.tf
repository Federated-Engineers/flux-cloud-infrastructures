# AWS BUCKET
# data "aws_s3_bucket" "csv_bucket" {
#   bucket = var.s3_bucket_name
# }

# CLOUDWATCH
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/sheet-transformer"
  retention_in_days = 30
}

# LAMBDA FUNCTION
data "aws_s3_object" "lambda_zip" {
  bucket = data.aws_s3_bucket.csv_bucket.id
  key    = "lambda-artifacts/sheet-transformer/${var.lambda_version}.zip"
}

data "aws_s3_object" "lambda_sha256" {
  bucket = data.aws_s3_bucket.csv_bucket.id
  key    = "lambda-artifacts/sheet-transformer/${var.lambda_version}.sha256"
}

resource "aws_lambda_function" "sheet_transformer" {
  function_name    = "sheet-transformer"
  s3_bucket        = data.aws_s3_object.lambda_zip.bucket
  s3_key           = data.aws_s3_object.lambda_zip.key
  source_code_hash = base64encode(trimspace(data.aws_s3_object.lambda_sha256.body))
  runtime          = "python3.12"
  handler          = "lambda_function.lambda_handler"
  role             = aws_iam_role.lambda_role.arn
  timeout          = 300

  layers = [
    "arn:aws:lambda:eu-central-1:336392948345:layer:AWSSDKPandas-Python312:14"
  ]

  environment {
    variables = {
      SHEET_KEY      = var.sheet_key
      SSM_PATH       = var.ssm_path
      S3_BUCKET_NAME = var.s3_bucket_name
    }
  }
}

# AWS TRANSFER SERVER
resource "aws_transfer_server" "sftp_server" {
  identity_provider_type = "SERVICE_MANAGED"
  protocols              = ["SFTP"]
}

# AWS LAMBDA ROLE AND POLICY
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

# AWS TRANFER USER
resource "aws_transfer_user" "partner" {
  server_id      = aws_transfer_server.sftp_server.id
  user_name      = "repair-partner"
  role           = aws_iam_role.transfer_role.arn
  home_directory = "/${data.aws_s3_bucket.csv_bucket.bucket}"
}

resource "aws_transfer_ssh_key" "partner_key" {
  server_id = aws_transfer_server.sftp_server.id
  user_name = aws_transfer_user.partner.user_name
  body      = file("repair-partner.pub")
}