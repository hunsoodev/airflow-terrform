# 현재 AWS 계정에서 사용 가능한 모든 가용 영역의 목록을 검색
# data.aws_availability_zones.available.names
data "aws_availability_zones" "available" {}

locals {

    name       = "airflow-vpc"   # vpc 이름
    cidr_block = "10.0.0.0/16"   # vpc cidr

    azs        = slice(data.aws_availability_zones.available.names, 0, 2) 
    # ["${local.region}a", "${local.region}b"]
    # 사용 가능한 AWS 가용 영역(Availability Zones, AZs) 목록에서 첫 두 개를 선택

    public_subnet_cidr_blocks      = [for idx, az in local.azs : cidrsubnet(local.cidr_block, 10, 1 + idx)]
    private_subnet_cidr_blocks     = [for idx, az in local.azs : cidrsubnet(local.cidr_block, 2, 1 + idx)]
    database_subnet_cidr_blocks    = [for idx, az in local.azs : cidrsubnet(local.cidr_block, 4, 1 + idx)]
    elasticache_subnet_cidr_blocks = [for idx, az in local.azs : cidrsubnet(local.cidr_block, 6, 1 + idx)]
    redshift_subnet_cidr_blocks    = [for idx, az in local.azs : cidrsubnet(local.cidr_block, 8, 1 + idx)]

    region      = "ap-northeast-2"
    environment = "prod"

    tags = {
        team        = "kdt-de-2nd"
        maintainer  = "hunsoo.jeong"
        environment = local.environment
        terraform   = "true"
  }
}
    