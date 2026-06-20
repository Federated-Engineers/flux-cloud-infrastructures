resource "aws_transfer_user" "partner" {
  server_id = aws_transfer_server.sftp_server.id
  user_name = "repair-partner"
  role = aws_iam_role.transfer_role.arn
  home_directory = "/${data.aws_s3_bucket.csv_bucket.bucket}"
}

resource "aws_transfer_ssh_key" "partner_key" {
  server_id = aws_transfer_server.sftp_server.id
  user_name = aws_transfer_user.partner.user_name
  body      = file("repair-partner.pub")
}