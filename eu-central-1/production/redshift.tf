
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

data "aws_vpc" "spreekauf-production" {
  id = var.production-vpc
}

data "aws_subnet" "spreekauf_subnet_a" {
  id = var.production-vpc-subnet-public-a
}

data "aws_subnet" "spreekauf_subnet_b" {
  id = var.production-vpc-subnet-public-b
}

resource "aws_redshift_subnet_group" "spreekauf_subnet_group" {
  name        = "spreekauf-subnet-group"
  description = "The subnet group for the SpreeKauf Redshift cluster"
  subnet_ids  = [data.aws_subnet.spreekauf_subnet_a.id, data.aws_subnet.spreekauf_subnet_b.id]

  tags = local.common_tags
}

resource "random_password" "spreekauf_master_password" {
  length  = 16
  special = false
}

resource "aws_ssm_parameter" "spreekauf_master_password" {
  name        = "/production/redshift/spreekauf/password"
  description = "The SpreeKauf Redshift cluster password"
  type        = "SecureString"
  value       = random_password.spreekauf_master_password.result

  tags = local.common_tags
}

resource "aws_security_group" "spreekauf_redshift_sg" {
  name        = "spreekauf-redshift-sg"
  description = "The security group for the SpreeKauf Redshift cluster"
  vpc_id      = data.aws_vpc.spreekauf-production.id

  tags = local.common_tags
}

resource "aws_vpc_security_group_ingress_rule" "spreekauf_redshift_ingress" {
  security_group_id = aws_security_group.spreekauf_redshift_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 5439
  to_port           = 5439
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "spreekauf_redshift_egress" {
  security_group_id = aws_security_group.spreekauf_redshift_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow all outbound traffic"
}

resource "aws_redshift_parameter_group" "spreekauf_parameter_group" {
  name        = "spreekauf-parameter-group"
  family      = "redshift-2.0"
  description = "Parameter group for SpreeKauf to configure WLM, SQA and QMR"

  parameter {
    name = "wlm_json_configuration"
    value = jsonencode([

      {
        name          = "etl-queue"
        priority      = "highest"
        auto_wlm      = true
        queue_type    = "auto"
        useeu-r_group = ["etl-job"]
      },

      {
        name                = "analyst-queue"
        priority            = "normal"
        auto_wlm            = true
        queue_type          = "auto"
        concurrency_scaling = "auto"
        user_group          = ["analyst_team"]
        rules = [
          {
            rule_name = "kill_lengthy_scan_queries"
            predicate = [
              {
                metric_name = "query_blocks_read"
                operator    = ">"
                value       = 2097152
              }
            ]
            action = "abort"
          },
          {
            rule_name = "deprioritize_cpu_hoggers"
            predicate = [
              {
                metric_name = "query_cpu_usage_percent"
                operator    = ">"
                value       = 80
              },
              {
                metric_name = "query_execution_time"
                operator    = ">"
                value       = 1200
              }
            ]
            action = "change_query_priority"
            value  = "lowest"
          }
        ]
      },

      {
        short_query_queue = true
      }
    ])
  }

  tags = local.common_tags
}


resource "aws_redshift_cluster" "spreekauf_predictive_cluster" {
  cluster_identifier  = "predictive-team-spreekauf"
  database_name       = "spreekauf_data_warehouse"
  master_username     = "spreekauf_GmBH_client"
  master_password     = aws_ssm_parameter.spreekauf_master_password.value
  node_type           = "rg.xlarge"
  cluster_type        = "multi-node"
  number_of_nodes     = 2
  publicly_accessible = true

  cluster_parameter_group_name = aws_redshift_parameter_group.spreekauf_parameter_group.name
  cluster_subnet_group_name    = aws_redshift_subnet_group.spreekauf_subnet_group.name
  vpc_security_group_ids       = [aws_security_group.spreekauf_redshift_sg.id]

  skip_final_snapshot       = false
  final_snapshot_identifier = "spreekauf-predictive-final-snapshot"

  tags = local.common_tags
}