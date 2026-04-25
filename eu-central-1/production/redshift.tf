
# data "aws_vpc" "nordic-secure-production" {
#   id = var.production-vpc
# }

# data "aws_subnet" "nordic-secure-production-subnet" {
#   id = var.production-vpc-subnet-public-a
# }

# data "aws_subnet" "nordic-secure-production-subnet-b" {
#   id = var.production-vpc-subnet-public-b
# }

# resource "aws_security_group" "nordic_security_group" {
#   vpc_id = data.aws_vpc.nordic-secure-production.id
# }

# resource "aws_vpc_security_group_ingress_rule" "nordic_ingress_rule" {
#   security_group_id = aws_security_group.nordic_security_group.id
#   cidr_ipv4         = "0.0.0.0/0"
#   from_port         = 5439
#   to_port           = 5439
#   ip_protocol       = "tcp"
# }

# resource "aws_vpc_security_group_egress_rule" "nordic_egress_rule" {
#   security_group_id = aws_security_group.nordic_security_group.id
#   cidr_ipv4         = "0.0.0.0/0"
#   ip_protocol       = "-1"
# }

# resource "aws_iam_role" "nordic_redshift_role" {
#   name = "nordic_redshift_role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Sid    = "AllowRedshiftAssumeRole"
#         Principal = {
#           Service = "redshift.amazonaws.com"
#         }
#       },
#     ]
#   })
# }

# resource "aws_iam_policy" "nordic_redshift_policy" {
#   name        = "flux_nordic_redshift_policy"
#   description = "My nordic policy"


#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = [
#           "s3:List*",
#           "s3:*Object*"

#         ]
#         Effect = "Allow"
#         Resource = [
#           "arn:aws:s3:::nordic_s3_bucket",
#           "arn:aws:s3:::nordic_s3_bucket/*",
#         ]
#       },
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "nordic-policy-attachment" {
#   role       = aws_iam_role.nordic_redshift_role.name
#   policy_arn = aws_iam_policy.nordic_redshift_policy.arn
# }

# resource "random_password" "redshift_nordic_password" {
#   length  = 16
#   special = false
# }

# resource "aws_ssm_parameter" "redshift_nordic_password" {
#   name  = "/production/redshift/nordic_retail_collective/password"
#   type  = "SecureString"
#   value = random_password.redshift_nordic_password.result
# }

# resource "aws_redshift_subnet_group" "redshift_nordic_subnet_group" {
#   name       = "nordic-subnet-group"
#   subnet_ids = [data.aws_subnet.nordic-secure-production-subnet.id, data.aws_subnet.nordic-secure-production-subnet-b.id]
# }

# resource "aws_redshift_cluster" "nordic-analytics-warehouse" {
#   cluster_identifier           = "analytics-warehouse"
#   database_name                = "nordic_logistics_warehouse"
#   master_username              = "nordic_retail_collective_user"
#   master_password              = aws_ssm_parameter.redshift_nordic_password.value
#   iam_roles                    = [aws_iam_role.nordic_redshift_role.arn]
#   node_type                    = "ra3.xlplus"
#   cluster_type                 = "single-node"
#   vpc_security_group_ids       = [aws_security_group.nordic_security_group.id]
#   preferred_maintenance_window = "sun:23:00-sun:23:30"
#   publicly_accessible          = true
#   skip_final_snapshot          = true
#   cluster_subnet_group_name    = aws_redshift_subnet_group.redshift_nordic_subnet_group.name
#   tags = merge(local.common_tags, {
#     Owner = "nordic-retail-collective"
#   })
# }
