data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "de-2-1-project-tfstates"
    key    = "dev-proj/vpc"
    region = "ap-northeast-2"
  }
}

data "terraform_remote_state" "metadata_db" {
  backend = "s3"
  config = {
    bucket = "de-2-1-project-tfstates"
    key    = "dev-proj/airflow/rds"
    region = "ap-northeast-2"
  }
}