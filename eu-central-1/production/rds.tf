data "aws_vpc" "alpine-secure-production" {
  id = var.production-vpc
}

data "aws_subnet" "alpine-secure-production-subnet1" {
  id = var.production-vpc-subnet-public-a
}

data "aws_subnet" "alpine-secure-production-subnet2" {
  id = var.production-vpc-subnet-public-b
}

resource "aws_db_subnet_group" "alpine-secure-production-subnet-group" {
  name       = "alpine-secure-production-subnet-group"
  subnet_ids = [data.aws_subnet.alpine-secure-production-subnet1.id, data.aws_subnet.alpine-secure-production-subnet2.id]

  tags = {
    Name = "Alpine secure production subnet group"
  }
}

resource "aws_security_group" "alpine_security_group" {
  vpc_id = data.aws_vpc.alpine-secure-production.id
}

resource "aws_vpc_security_group_ingress_rule" "alpine_ingress_rule" {
  security_group_id = aws_security_group.alpine_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 5432
  to_port           = 5432
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "alpine_egress_rule" {
  security_group_id = aws_security_group.alpine_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "random_password" "rds-alpine-password" {
  length  = 16
  special = true
}

resource "aws_ssm_parameter" "rds-alpine-password" {
  name  = "/production/rds/alpine/password"
  type  = "SecureString"
  value = random_password.rds-alpine-password.result
}

resource "aws_db_instance" "alpine_db" {
  allocated_storage      = 10
  identifier = "alpine-db-instance"
  db_name                = "alpine_db"
  engine                 = "postgres"
  engine_version         = "17.6"
  instance_class         = "db.t4g.small"
  username               = "alpine_db_user"
  password               = random_password.rds-alpine-password.result
  parameter_group_name   = "default.postgres17"
  skip_final_snapshot    = true
  publicly_accessible    = true
  db_subnet_group_name   = aws_db_subnet_group.alpine-secure-production-subnet-group.name
  vpc_security_group_ids = [aws_security_group.alpine_security_group.id]
}
