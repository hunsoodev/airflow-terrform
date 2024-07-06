data "aws_availability_zones" "available" {}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "de-2-1-project-tfstates" # [github account]-tfstates & hunsoodev-tfstates
    key    = "dev-proj/vpc"       # [github repo]/vpc
    region = "ap-northeast-2"
  }
}