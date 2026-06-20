variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "eu-central-1"
}

variable "team" {
  description = "The team responsible for the deployment"
  type        = string
  default     = "flux-data-engineers"
}

variable "environment" {
  description = "The environment for the deployment"
  type        = string
  default     = "staging"
}

variable "project" {
  description = "The project owner"
  type        = string
  default     = "Federated-Engineers"
}

variable "aws_region" {
  default = "eu-central-1"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for storing transformed CSV files"
  type        = string
  default = "alpenmechanik-datalake"
}

variable "sheet_key" {
  description = "Google Sheet ID"
  type        = string
}

variable "ssm_path" {
  description = "SSM Parameter path containing credentials"
  type        = string
}

variable "lambda_version" {
  description = "Git SHA of the ETL repo build to deploy"
  type        = string
  default = "latest"
}