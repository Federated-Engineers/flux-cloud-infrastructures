module "riveira_bucket" {
source = "../modules/s3_bucket"
bucket-use-case = "riveira-dataset"
versioning = "Enabled"
team ="flux-cloud-infrastructures"
environment = "prod"
service = "data-lake"
}
