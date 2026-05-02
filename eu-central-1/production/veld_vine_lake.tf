module "veldvine-bucket"{
    source ="../modules/s3-bucket"

    environment     = "production"
    team            = "flux"
    bucket-use-case = "veld_vine"
    versioning      = "Enabled"
    service         = "flux-airflow"
}
