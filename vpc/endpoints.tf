module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "5.5.0"

  vpc_id = module.airflow_vpc.vpc_id

  # VPC 엔드포인트용 보안 그룹을 자동으로 생성
  create_security_group      = true
  security_group_name_prefix = "${local.name}-endpoints-sg"
  security_group_description = "VPC endpoint security group"
  security_group_rules = {
    ingress_https = { # ingress_https를 식별자로 사용
      description = "HTTPS from VPC"
      cidr_blocks = [module.airflow_vpc.vpc_cidr_block]
      # VPC의 CIDR 블록 내부에서만 HTTPS 트래픽을 허용하도록 설정 -> vpc_cidr_block은 ouput에 정의되어 있음
    }
  }

  # VPC 엔드포인트 설정
  endpoints = {
    # s3_gateway라는 키를 정의
    s3_gateway = {
      service         = "s3"
      service_type    = "Gateway"  # VPC 엔드포인트의 타입 지정
      route_table_ids = flatten([  # 여러 리스트를 하나의 리스트로 평탄화
      # VPC 내의 모든 영역(내부, 프라이빗, 공용)에 적용하기 위함
                        module.airflow_vpc.intra_route_table_ids, 
                        module.airflow_vpc.private_route_table_ids, 
                        module.airflow_vpc.public_route_table_ids
                        ])
      # 엔드포인트에 적용할 IAM 정책을 지정
      # policy          = data.aws_iam_policy_document.s3_gateway_endpoint_policy.json
      tags            = { Name = "${local.name}/s3-vpc-endpoint" }
    },
    rds = {   # 인터페이스 타입 엔드포인트
      service             = "rds"
      private_dns_enabled = true      # 엔드포인트에 대한 프라이빗 DNS 이름을 생성하고 활성화함
      subnet_ids          = module.airflow_vpc.private_subnets # 지정된 프라이빗 서브넷들에 RDS 엔드포인트를 배치
      security_group_ids  = [aws_security_group.rds.id]  
      # 엔드포인트와 통신을 허용할 보안 그룹의 ID 목록
      # 보안 그룹에 속한 리소스만이 RDS 엔드포인트를 통해 데이터베이스에 접근할 수 있도록 제한할 수 있음
      tags                = { Name = "${local.name}/rds-vpc-endpoint" }
    },
  }

  # merge : 두 개 이상의 맵(키-값 쌍의 집합)을 하나로 결합하는 데 사용
  tags = merge(local.tags, {
    endpoint = "true"
  }) # local.tags에 정의도니 모든 태그를 상속받고 추가로 endpoint: "true" 태그도 포함
}

#  AWS Identity and Access Management(IAM) 정책 문서를 정의 
# S3 게이트웨이 엔드포인트에 적용될 IAM 정책을 정의 -> 특정 조건에서 S3 서비스에 대한 액세스를 제어하는 데 사용
data "aws_iam_policy_document" "s3_gateway_endpoint_policy" {
  statement {
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = ["*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "StringNotEquals"
      variable = "aws:sourceVpc"

      values = [module.airflow_vpc.vpc_id]
    }
  }
}
# -> VPC 엔드포인트를 통해 S3에 액세스하는 요청을 제어하기 위한 것
# 지정된 VPC (module.airflow_vpc.vpc_id)에서 오는 요청을 제외하고, 모든 S3 액션을 거부하는 정책을 정의함
# VPC 엔드포인트를 사용하여 특정 VPC에서만 S3 서비스에 접근을 허용하고, 그 외의 출처에서 오는 요청을 제한하려는 경우에 유용

# 일반적인 VPC 엔드포인트에 대한 접근 제어 정책 생성
# 특정 VPC에서 시작되지 않은 모든 요청을 거부하는 IAM 정책 생성
data "aws_iam_policy_document" "generic_endpoint_policy" {
  statement {
    effect    = "Deny"
    actions   = ["*"]
    resources = ["*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "StringNotEquals"
      variable = "aws:SourceVpc"

      values = [module.airflow_vpc.vpc_id]
      # 특정 VPC에서 오는 요청만을 허용하고 다른 VPC에서 오는 요청은 거부
    }
  }
}

# rds endpoint에 대한 보안그룹 생성 
resource "aws_security_group" "rds" {
  name_prefix = "${local.name}-rds"
  description = "Allow PostgreSQL inbound traffic"
  vpc_id      = module.airflow_vpc.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [module.airflow_vpc.vpc_cidr_block]
  }

  tags = local.tags
}