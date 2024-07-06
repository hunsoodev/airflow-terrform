locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  region      = "ap-northeast-2"
  environment = "prod"
  
  instance_type = "t3.small"
  # key_name = "de-2-1-key" # 개인 키 파일 이름 지정

  # 다른 테라폼 프로젝트의 상태 정보에서 가져옴
  database_endpoint  = data.terraform_remote_state.metadata_db.outputs.db_instance_address
  database_secret_id = data.terraform_remote_state.metadata_db.outputs.db_instance_master_user_secret_arn
  redis_endpoint     = data.terraform_remote_state.celery_broker.outputs.primary_endpoint_address
  redis_secret_id    = data.terraform_remote_state.celery_broker.outputs.secret_arn

  tags = {
    team        = "kdt-de-2nd"
    maintainer  = "hunsoo.jeong"
    environment = local.environment
    terraform   = "true"
  }
}