resource "aws_iam_role" "glue_role" {
  name = "glue_role"


  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "glue_role"
  }
}

resource "aws_iam_policy" "glue_policy" {
  name = "glue_gold_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [


      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::veld-vine-s3",
          "arn:aws:s3:::veld-vine-s3/silver/*",
          "arn:aws:s3:::veld-vine-s3/gold/*"
        ]
      },

      {
        Effect   = "Allow"
        Action   = "glue:*"
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = "athena:*"
        Resource = "*"
      }

    ]
  })
}

resource "aws_iam_role_policy_attachment" "glue_policy_attach" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_policy.arn
}