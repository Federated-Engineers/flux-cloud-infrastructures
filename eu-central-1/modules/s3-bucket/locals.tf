locals {
  common_tags = {
    team        = var.team
    environment = var.environment
    terraform   = true
  }
}