locals {
  cluster_id = "airflow-celery-broker"
  engine     = "redis"
  node_type  = "cache.t4g.small"

  region      = "ap-northeast-2"
  environment = "prod"

  tags = {
    team        = "kdt-de-2nd"
    maintainer  = "hunsoo.jeong"
    environment = local.environment
    terraform   = "true"
  }
}