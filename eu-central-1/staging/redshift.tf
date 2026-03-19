
data "aws_vpc" "nordic_vpc" {
  #   id = data.aws_vpc.secure_production.id
  filter {
    name   = "tag:Name"
    values = ["secure-production"]
  }
}

data "aws_subnet" "nordic_subnet" {
  filter {
    name   = "tag:Name"
    values = ["secure-production-public-a"]
  }
}

resource "aws_security_group" "subnet_security_group" {
  vpc_id = data.aws_subnet.nordic_subnet.id

  ingress {
    cidr_blocks = [data.aws_subnet.nordic_subnet.cidr_block]
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "random_password" "redshift_nordic_password" {
  length  = 16
  special = true
}


resource "aws_iam_role" "nordic_redshift_role" {
  name = "nordic_redshift_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "redshift.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "nordic_redshift_policy" {
  name        = "nordic_redshift_policy"
  path        = "/"
  description = "My nordic policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutObject*",
          "s3:ListObject*",
          "s3:GetObject*"

        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "glue:*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "nordic-policy-attachment" {
  role       = aws_iam_role.nordic_redshift_role.name
  policy_arn = aws_iam_policy.nordic_redshift_policy.arn
}

resource "aws_redshift_cluster" "example" {
  cluster_identifier = "analytics-warehouse"
  database_name      = "nordic_logistics_warehouse"
  master_username    = var.master_username
  master_password    = random_password.redshift_nordic_password.result
  iam_roles          = [aws_iam_role.nordic_redshift_role.arn]
  node_type          = "dc1.large"
  cluster_type       = "single-node"
}