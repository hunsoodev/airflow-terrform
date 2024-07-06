terraform {
  # vpc에 관련된 terraform 상태 파일 저장 경로
  backend "s3" {
    bucket = "de-2-1-project-tfstates" # [github account(?)]-tfstates & [project-name]-tfstates
    key    = "dev-proj/vpc"       # 참고: [github repo]/vpc
    region = "ap-northeast-2"
  }
}

provider "aws" {
  region                  = local.region
  skip_metadata_api_check = true
  profile = "default"
}