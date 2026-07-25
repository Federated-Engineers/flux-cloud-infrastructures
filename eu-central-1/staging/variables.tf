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