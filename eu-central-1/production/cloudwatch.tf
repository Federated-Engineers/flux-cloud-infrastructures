resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/sheet-transformer"
  retention_in_days = 30
}