
data "aws_vpc" "secure-production" {
  id = var.vpc_id
}

resource "aws_subnet" "secure-production" {
  vpc_id = data.aws_vpc.secure-production.id
}


resource "aws_security_group" "nordic_security_group" {
  vpc_id = data.aws_vpc.secure-production.id
}


resource "aws_security_group_rule" "nordic_ingress_rule" {
  type                     = "ingress"
  from_port                = 5439
  to_port                  = 5439
  protocol                 = "tcp"
  security_group_id        = aws_security_group.nordic_security_group.id
  source_security_group_id = aws_security_group.nordic_security_group.id
}

resource "aws_security_group_rule" "nordic_egress_rule" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.nordic_security_group.id
  cidr_blocks       = ["0.0.0.0/0"]
}


resource "random_password" "redshift_nordic_password" {
  length  = 16
  special = true
}


resource "aws_ssm_parameter" "redshift_nordic_password" {
  name  = "redshift_nordic_password"
  type  = "SecureString"
  value = random_password.redshift_nordic_password.result
}


resource "aws_iam_role" "nordic_redshift_role" {
  name = "nordic_redshift_role"


  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "AllowRedshiftAssumeRole"
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


  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutObject*",
          "s3:ListObject*",
          "s3:GetObject*"

        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::nordic_s3_bucket",
          "arn:aws:s3:::nordic_s3_bucket/*",
        ]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "nordic-policy-attachment" {
  role       = aws_iam_role.nordic_redshift_role.name
  policy_arn = aws_iam_policy.nordic_redshift_policy.arn
}

resource "aws_redshift_cluster" "nordic-analytics-warehouse" {
  cluster_identifier = "analytics-warehouse"
  database_name      = "nordic_logistics_warehouse"
  master_username    = aws_iam_user.nordic_user.name
  master_password    = random_password.redshift_nordic_password.result
  iam_roles          = [aws_iam_role.nordic_redshift_role.arn]
  node_type          = "ra3.xlplus"
  cluster_type       = "single-node"
}