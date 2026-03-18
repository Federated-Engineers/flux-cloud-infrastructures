variable "team" {
  description = "The team responsible for the deployment"
  type        = string
}

variable "environment" {
  description = "The environment for the deployment (e.g production, staging, dev)"
  type        = string
}

variable "bucket-use-case" {
  description = "Use case of the bucket (e.g. logs, data-lake, sftp)"
  type        = string
}

variable "service" {
  description = "The service using the bucket (e.g. lambda, glue, sagemaker, ec2, etc.)"
  type        = string
}

variable "versioning" {
  description = "versioning status for the S3 bucket (Enabled/Disabled)"
  type        = string
}