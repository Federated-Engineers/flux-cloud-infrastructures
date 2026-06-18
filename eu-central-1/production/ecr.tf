resource "aws_ecr_repository" "flux_airflow" {
  name                 = "flux-airflow"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(local.common_tags, { Name = "flux-airflow" })
}

resource "aws_ecr_lifecycle_policy" "flux_airflow_policy" {
  repository = aws_ecr_repository.flux_airflow.name

  policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Expire images but keep the last 2 untagged images",
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": 2
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}



resource "aws_ecr_repository" "flux_lsa_dbt" {
  name                 = "flux-lsa-dbt"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(local.common_tags, { Name = "flux-lsa-dbt" })
}

resource "aws_ecr_lifecycle_policy" "flux_lsa_dbt_policy" {
  repository = aws_ecr_repository.flux_lsa_dbt.name

  policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Expire images but keep the last 2 untagged images",
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": 2
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}