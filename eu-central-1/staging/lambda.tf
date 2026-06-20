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