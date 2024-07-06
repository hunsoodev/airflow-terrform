terraform {
  backend "s3" {
    bucket = "de-2-1-project-tfstates"
    key    = "dev-proj/airflow/ec2"
    region = "ap-northeast-2"
  }
}

provider "aws" {
  region                  = local.region
  skip_metadata_api_check = true
  profile                 = "default"
}