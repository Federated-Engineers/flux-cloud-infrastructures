
data "aws_vpc" "nordic-secure-production" {
  id = var.production-vpc
}

data "aws_subnet" "nordic-secure-production-subnet" {
  id = var.production-vpc-subnet-public-a
}

resource "aws_security_group" "nordic_security_group" {
  vpc_id = data.aws_vpc.nordic-secure-production.id
}

resource "aws_vpc_security_group_ingress_rule" "nordic_ingress_rule" {
  security_group_id = aws_security_group.nordic_security_group.id
  cidr_ipv4         = data.aws_vpc.nordic-secure-production.cidr_block
  from_port         = 5432
  ip_protocol       = "tcp"
  to_port           = 5432
}

resource "aws_vpc_security_group_egress_rule" "nordic_egress_rule" {
  security_group_id = aws_security_group.nordic_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
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

resource "aws_ssm_parameter" "redshift_nordic_username" {
  name  = "/production/redshift/nordic_retail_collective/username"
  type  = "String"
  value = "nordic_retail_collective_user"
}

resource "random_password" "redshift_nordic_password" {
  length  = 16
  special = true
}

resource "aws_ssm_parameter" "redshift_nordic_password" {
  name  = "/production/redshift/nordic_retail_collective/password"
  type  = "SecureString"
  value = random_password.redshift_nordic_password.result
}

resource "aws_redshift_cluster" "nordic-analytics-warehouse" {
  cluster_identifier           = "analytics-warehouse"
  database_name                = "nordic_logistics_warehouse"
  master_username              = aws_ssm_parameter.redshift_nordic_username.value
  master_password              = aws_ssm_parameter.redshift_nordic_password.value
  iam_roles                    = [aws_iam_role.nordic_redshift_role.arn]
  node_type                    = "ra3.xlplus"
  cluster_type                 = "single-node"
  vpc_security_group_ids       = [aws_security_group.nordic_security_group.id]
  preferred_maintenance_window = "sun:23:00-sun:23:30"
  publicly_accessible          = true
  tags = merge(local.common_tags, {
    Owner = "nordic-retail-collective"
  })
}