
################################################################################
# RDS
################################################################################

# https://github.com/terraform-aws-modules/terraform-aws-rds/blob/master/examples/complete-postgres/main.tf
module "arflow_metadata_db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.4.0"

  identifier = local.name

  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
  engine               = local.engine
  engine_version       = local.engine_version
  family               = local.family         # DB parameter group
  major_engine_version = local.engine_version # DB option group
  instance_class       = local.instance_class

  allocated_storage     = 10
  max_allocated_storage = 30

  # NOTE: Do NOT use 'user' as the value for 'username' as it throws:
  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
  # user cannot be used as it is a reserved word used by the engine"
  db_name                     = local.db_name
  username                    = local.username
  port                        = local.port
  manage_master_user_password = local.manage_master_user_password

  # setting manage_master_user_password_rotation to false after it
  # has been set to true previously disables automatic rotation
  # aws rds 데이터베이스 인스턴스의 마스터 사용자 비밀번호 자동 회전 기능
  manage_master_user_password_rotation              = false  # 자동 회전 비활성화 
  master_user_password_rotate_immediately           = false  # terraform이 리소스를 적용할 때 비밀번호 회전을 즉시 시작할지 여부 
  master_user_password_rotation_schedule_expression = "rate(15 days)" # 비밀번호 회전의 일정을 지정 (15일마다 회전)

  multi_az               = true
  db_subnet_group_name   = data.terraform_remote_state.vpc.outputs.database_subnet_group
  vpc_security_group_ids = [module.security_group.security_group_id]

  # AWS RDS 인스턴스의 유지 관리, 백업, 로깅 전략을 구성
  maintenance_window              = "Mon:00:00-Mon:03:00" # 매주 월요일 자정부터 새벽 3시까지의 시간대에 유지 관리 작업 수행
  backup_window                   = "03:00-06:00"         # 매일 새벽 3시부터 6시 사이에 백업 작업 수행
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"] # postgresql 데이터베이스 로그와 업그레이드 관련 로그를 CLoudWatch로 내보내도록 설정
  create_cloudwatch_log_group     = true   # terraform이 로그로 내보낼 Cloudwatch 로그 그룹을 자동으로 생성할지 여부를 결정

  # aws rds 인스턴스의 백업 보존, 종료 시 스냅샷 생성 여부, 그리고 삭제 보호 기능 구성
  backup_retention_period = 1     # 백업은 1일 동안 보관된 후 자동으로 삭제
  skip_final_snapshot     = true  # rds 인스턴스를 삭제할 떄 최종 스냅샷을 생성할지 여부 (true: reds 인스턴스 삭제 시 최종 스냅샷을 생성하지 않음)
  deletion_protection     = false # 삭제 보호 기능 비활성화
  
  # performance insights : 데이터베이스 부하 모니터링, 성능 문제 원인 분석 가능
  performance_insights_enabled          = false   # performance insights 기능 활성화 여부
  performance_insights_retention_period = 7       # performance insights 데이터를 유지 보관하는 기간(일 단위)
  create_monitoring_role                = false   # rds 인스턴스의 performance data를 cloudwatch에 발행 하기 위한 iam 역할을 terraform이 자동으로 생성할지 여부를 결정
  monitoring_interval                   = 0       # rds 인스턴스의 performance data를 cloudwatch로 보내는 간격(초 단위)
  monitoring_role_name                  = "example-monitoring-role-name"
  monitoring_role_use_name_prefix       = true    # 지정된 monitoring_role_name을 이름 접두사로 사용할지 여부
  monitoring_role_description           = "Description for monitoring role"

  parameters = [ # 각 파라미터는 데이터베이스의 동작 방식을 조정하는 데 사용함
    {
      name  = "autovacuum" # 자동 바큠 기능 제어 : 사용하지 않는 공간을 회수하고, 데이터베이스의 성능을 최적화함
      value = 1
    },
    {
      name  = "client_encoding"
      value = "utf8"
    }
  ]

  tags = local.tags
  db_option_group_tags = {
    "Sensitive" = "low" # 데이터베이스 옵션 그룹의 민감도 수준 -> low : 민감한 정보를 다루지 않는 경우
  }
  db_parameter_group_tags = {
    "Sensitive" = "low" # 파라미터 그룹의 민감도 수준 -> 파라미터 그룹이 민감한 데이터베이스 설정을 포함하지 않는다는 것을 의미
  }
}

#module "db_default" {
#  source = "terraform-aws-modules/rds/aws"
#  version = "6.4.0"
#
#  identifier                     = "${local.name}-default"
#  instance_use_identifier_prefix = true
#
#  create_db_option_group    = false
#  create_db_parameter_group = false
#
#  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
#  engine               = "postgres"
#  engine_version       = "14"
#  family               = "postgres14" # DB parameter group
#  major_engine_version = "14"         # DB option group
#  instance_class       = "db.t4g.large"
#
#  allocated_storage = 20
#
#  # NOTE: Do NOT use 'user' as the value for 'username' as it throws:
#  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
#  # user cannot be used as it is a reserved word used by the engine"
#  db_name  = "completePostgresql"
#  username = "complete_postgresql"
#  port     = 5432
#
#  db_subnet_group_name   = database_subnet_group
#  vpc_security_group_ids = [module.security_group.security_group_id]
#
#  maintenance_window      = "Mon:00:00-Mon:03:00"
#  backup_window           = "03:00-06:00"
#  backup_retention_period = 0
#
#  tags = local.tags
#}


################################################################################
# Supporting Resources
################################################################################

# rds secuirty-group이 기본으로 생성되는 것 같은데(?) -> module 안써도 될 것 같은..?
module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${local.name}-sg"   # airflow-metadata-database-sg
  description = "Allow DB access from within VPC"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "DB access from within VPC"
      cidr_blocks = data.terraform_remote_state.vpc.outputs.vpc_cidr_block
    },
  ]

  tags = local.tags
}

#resource "aws_db_instance" "airflow_db" {
#  allocated_storage    = 20
#  engine               = "postgres"
#  engine_version       = "12.4"
#  instance_class       = "db.t3.micro"
#  name                 = "airflow"
#  username             = "airflow"
#  password             = "yourSecurePassword"
#  skip_final_snapshot  = true
#  publicly_accessible  = false
#  vpc_security_group_ids = [aws_security_group.airflow_db_sg.id]
#}
#
#resource "aws_security_group" "airflow_db_sg" {
#  name        = "airflow-db-sg"
#  description = "Allow Airflow components to communicate with the DB"
#  vpc_id      = aws_vpc.main.id
#
#  ingress {
#    from_port   = 5432
#    to_port     = 5432
#    protocol    = "tcp"
#    cidr_blocks = ["10.0.0.0/16"]
#  }
#
#  egress {
#    from_port   = 0
#    to_port     = 0
#    protocol    = "-1"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#}

