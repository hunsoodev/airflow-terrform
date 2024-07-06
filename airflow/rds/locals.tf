locals {
  name                 = "airflow-metadata-database"  # 생성할 리소스의 이름
  engine               = "postgres"                   # 사용할 데이터베이스 엔진
  engine_version       = "14"                         # 사용할 데이터베이스 엔진의 버전
  family               = "postgres14" # DB parameter group을 위한 parameter faily 지정 ✔️
  major_engine_version = "14"         # DB option group을 위한 주요 엔진 버전 ✔️
  instance_class       = "db.t3.medium"

  db_name                     = "airflow"          # db 이름
  username                    = "airflow_admin"    # 데이터베이스 마스터 사용자 이름
  port                        = 5432
  manage_master_user_password = true        
  # 마스터 사용자의 비밀번호를 terraform이 관리할지 여부를 지정
  # AWS Secrets Manager 같은 서비스를 사용하여 안전하게 관리하자 ✔️

  azs       = slice(data.aws_availability_zones.available.names, 0, 2)
  subnet_id = data.terraform_remote_state.vpc.outputs.database_subnets  # ✔️

  region      = "ap-northeast-2"
  environment = "prod"

  tags = {
    team        = "kdt-de-2nd"
    maintainer  = "hunsoo.jeong"
    environment = local.environment
    terraform   = "true"
  }
}