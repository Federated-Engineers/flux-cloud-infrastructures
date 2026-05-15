data "aws_security_group" "selected" {
  vpc_id = var.production-vpc
  name   = "default"
}

resource "aws_security_group" "rds_postgres_sg" {
  name        = "rds-postgres-security-group"
  description = "Security group for RDS PostgreSQL instance"
  vpc_id      = var.production-vpc

  tags = local.common_tags
}

resource "aws_vpc_security_group_ingress_rule" "postgres_from_dms" {
  security_group_id            = aws_security_group.rds_postgres_sg.id
  referenced_security_group_id = data.aws_security_group.selected.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  description                  = "Allow PostgreSQL connections from DMS (default SG)"
}

resource "aws_vpc_security_group_ingress_rule" "postgres_from_source_server" {
  security_group_id            = aws_security_group.rds_postgres_sg.id
  cidr_ipv4                    = "109.199.115.167/32"
  ip_protocol                  = "-1"
  description                  = "Allow PostgreSQL connections from DS-Factory Server"
}

resource "aws_vpc_security_group_ingress_rule" "postgres_from_internet_2" {
  security_group_id            = aws_security_group.rds_postgres_sg.id
  cidr_ipv4                    = "0.0.0.0/0"
  ip_protocol                  = "-1"
  description                  = "Allow PostgreSQL connections from internet"
}


# resource "aws_vpc_security_group_egress_rule" "postgres_egress" {
#   security_group_id = aws_security_group.rds_postgres_sg.id
#   cidr_ipv4         = "0.0.0.0/0"
#   ip_protocol       = "-1"
#   description       = "Allow all outbound traffic"
# }

resource "aws_db_instance" "vitava_transact_db" {
  allocated_storage                   = 24
  apply_immediately                   = true
  backup_retention_period             = 7
  db_subnet_group_name                = aws_db_subnet_group.flux_de_db_subnet_group.name
  db_name                             = "postgres"
  engine                              = "postgres"
  engine_version                      = "18.1"
  identifier                          = "${var.environment}-vitavadb"
  instance_class                      = "db.t3.micro"
  password                            = aws_ssm_parameter.database_password.value
  username                            = aws_ssm_parameter.database_user.value
  multi_az                            = false
  storage_type                        = "gp3"
  skip_final_snapshot                 = true
  # publicly_accessible                 = true
  iam_database_authentication_enabled = true
  license_model                       = "postgresql-license"
  vpc_security_group_ids              = [aws_security_group.rds_postgres_sg.id]
  
  parameter_group_name = aws_db_parameter_group.postgres_dms_parameter_group.name
  tags                 = local.common_tags
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [var.production-vpc]
  }
  filter {
    name   = "tag:Name"
    values = ["secure-production-private-a", "secure-production-private-b"]
  }
}
  
resource "aws_db_subnet_group" "flux_de_db_subnet_group" {
  name       = "vitava_db_subnet_group"
  subnet_ids = concat(data.aws_subnets.private.ids, [var.production-vpc-subnet-public-a, var.production-vpc-subnet-public-b])

  tags = local.common_tags
}

resource "aws_db_parameter_group" "postgres_dms_parameter_group" {
  name = "postgres-dms-parameter-group"
  family = "postgres18"
  description = "Parameter group for PostgreSQL with DMS connection settings"

  parameter {
    name = "rds.force_ssl"
    value = 0
  }

  parameter {
    name  = "wal_sender_timeout"
    value = 72000
  }

  parameter {
    name  = "max_wal_senders"
    value = 10
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "max_replication_slots"
    value = 10
    apply_method = "pending-reboot"
  }


  parameter {
    name = "rds.logical_replication"
    value = 1
    apply_method = "pending-reboot"
  }

  tags = local.common_tags
}

resource "random_password" "db_password" {
  length           = 16
  special          = false
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_ssm_parameter" "database_host" {
  name  = "/${var.environment}/${var.team}/rds-db/endpoint"
  type  = "String"
  value = aws_db_instance.vitava_transact_db.endpoint

  tags = local.common_tags
}


resource "aws_ssm_parameter" "database_user" {
  name  = "/${var.environment}/${var.team}/rds-db/user"
  type  = "String"
  value = "flux_admin"

  tags = local.common_tags
}

resource "aws_ssm_parameter" "database_password" {
  name  = "/${var.environment}/${var.team}/rds-db/pwd"
  type  = "String"
  value = random_password.db_password.result

  tags = local.common_tags
}