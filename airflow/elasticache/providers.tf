terraform {
  backend "s3" {
    bucket = "de-2-1-project-tfstates"
    key    = "dev-proj/airflow/elasticache"
    region = "ap-northeast-2"
  }
}

# 리소스 이름, 비밀번호, 고유 식발자 등을 무작위로 생성할 수 있음
# 다수의 리소스를 동적으로 생성하고 관리할 때 유용
provider "random" {}

provider "aws" {
  region                  = local.region
  # skip_metadata_api_check = true
  profile                 = "default"
}