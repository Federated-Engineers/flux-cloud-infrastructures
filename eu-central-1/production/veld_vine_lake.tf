module "veldvine-bucket"{
    source ="../modules/s3-bucket"

    environment     = var.environment
    team            = var.team
    bucket-use-case = "veld_vine"
    versioning      = "Enabled"
    service         = "flux-airflow"
}

