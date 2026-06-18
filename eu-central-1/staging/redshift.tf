# data "aws_vpc" "default" {
#   default = true
#   region = "eu-north-1"
# }


# data "aws_subnets" "default" {
#   filter {
#     name   = "vpc-id"
#     values = [data.aws_vpc.default.id]
#   }
# }


# resource "aws_redshift_cluster" "example" {
#   cluster_identifier = "dbt-poc"
#   database_name      = "dev"
#   master_username    = "infra-admin"
#   master_password    = "Mustbe8characters"
#   node_type          = "dc1.large"
#   cluster_type       = "single-node"
#   region = "eu-north-1"
#   publicly_accessible = true
#   vpc_security_group_ids = [aws_security_group.redshift.id]
#   subnet_group_name = aws_redshift_subnet_group.example.name
#   tags = merge(local.common_tags, {
#     Name    = "dbt-poc",
#     Service = var.service
#   })
# }


# resource "aws_redshift_subnet_group" "foo" {
#   name       = "foo"
#   subnet_ids = [aws_subnet.foo.id, aws_subnet.bar.id]

#   tags = {
#     environment = "Production"
#   }
# }
