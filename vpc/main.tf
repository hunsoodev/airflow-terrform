################################################################################
# VPC Module
################################################################################

module "airflow_vpc" {
  # 공식 Terraform AWS VPC 모듈의 저장소 주소
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.0"

  name           = local.name       # VPC에 할당할 이름
  cidr           = local.cidr_block # VPC CIDR 블록

  azs                 = local.azs # 사용할 az의 리스트
  private_subnets     = local.private_subnet_cidr_blocks
  public_subnets      = local.public_subnet_cidr_blocks
  database_subnets    = local.database_subnet_cidr_blocks
  elasticache_subnets = local.elasticache_subnet_cidr_blocks
  redshift_subnets    = local.redshift_subnet_cidr_blocks

  # 데이터베이스 서브넷 그룹을 생성할지 여부를 지정
  create_database_subnet_group  = true

  # 기본 네트워크 ACL을 관리할지 여부
  manage_default_network_acl    = false
  manage_default_route_table    = false
  manage_default_security_group = false

  # internet_gateway를 생성하고 퍼블릭 라우팅 테이블에 연결함
  # enable_internet_gateway = true (x) 알아서 연결됨

  enable_dns_hostnames  = true
  enable_dns_support    = true

  enable_nat_gateway    = true
  single_nat_gateway    = false
  enable_vpn_gateway    = false

  enable_dhcp_options   = true

  # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
  enable_flow_log                        = false
  create_flow_log_cloudwatch_log_group   = false
  create_flow_log_cloudwatch_iam_role    = false
  flow_log_max_aggregation_interval      = 60

  tags = local.tags
}

