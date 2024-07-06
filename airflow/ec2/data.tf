# 현재 호출자의 신원 정보를 검색 (현재 호출자: Treraform 명령을 실행하는 AWS 계정 또는 IAM 역할을 말함)
data "aws_caller_identity" "current" {}
# account_id : 현재 호출자의 aws 계정 id
# user_id : 현재 호출자의 고유 식별자
# arn : 현재 호출자의 ARN -> ARN은 AWS 리소스를 고유하게 식별하는 데 사용되는 문자열

data "aws_availability_zones" "available" {}

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

data "terraform_remote_state" "celery_broker" {
  backend = "s3"
  config = {
    bucket = "de-2-1-project-tfstates"
    key    = "dev-proj/airflow/elasticache"
    region = "ap-northeast-2"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Ubuntu's owner ID
}

# data "aws_ami" "amazon-linux-2" {
#   most_recent = true
#   owners      = ["amazon"]
#   name_regex  = "amzn2-ami-hvm*"
# }