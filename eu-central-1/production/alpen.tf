# AWS TRANSFER SERVER
resource "aws_transfer_server" "sftp_server" {
  identity_provider_type = "SERVICE_MANAGED"
  protocols              = ["SFTP"]
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
          module.alpenmechanik-bucket.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = [
          "${module.alpenmechanik-bucket.arn}/*"
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
  home_directory = "/${module.alpenmechanik-bucket.bucket_name}"
}

data "aws_ssm_parameter" "repair_partner_pub" {
  name = "/production/flux/alpen_mechaniks/sftp_server/repair-partner.pub"
}

resource "aws_transfer_ssh_key" "partner_key" {
  server_id = aws_transfer_server.sftp_server.id
  user_name = aws_transfer_user.partner.user_name
  body      = data.aws_ssm_parameter.repair_partner_pub.value
}