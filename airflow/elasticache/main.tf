# 간단한 캐싱 시나리오나 개발/테스트 환경에서 주로 사용함
resource "aws_elasticache_cluster" "airflow_celery_broker" {
  cluster_id      = local.cluster_id
  engine          = local.engine
  node_type       = local.node_type
  num_cache_nodes = 1
  port            = 6379

  subnet_group_name = data.terraform_remote_state.vpc.outputs.elasticache_subnet_group_name
  security_group_ids = [module.airflow_celery_broker_sg.security_group_id]

  tags = {
    Name = "${local.cluster_id}-${local.engine}"
  }
}

# 프로덕션 환경에 적합
resource "aws_elasticache_replication_group" "airflow_celery_broker" {
  replication_group_id = "${local.cluster_id}-replication-group"
  description          = "Replication group for the Celery broker"

  node_type          = local.node_type
  num_cache_clusters = 1
  port               = 6379
  subnet_group_name  = data.terraform_remote_state.vpc.outputs.elasticache_subnet_group_name
  security_group_ids = [module.airflow_celery_broker_sg.security_group_id]

  transit_encryption_enabled = true
  auth_token                 = aws_secretsmanager_secret_version.redis_secret.secret_string
  auth_token_update_strategy = "ROTATE"
}

module "airflow_celery_broker_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${local.cluster_id}-sg"
  description = "Allow Redis access from VPC"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id


  ingress_with_cidr_blocks = [
    {
      from_port   = 6379
      to_port     = 6379
      protocol    = "tcp"
      description = "Redis access from VPC"
      cidr_blocks = data.terraform_remote_state.vpc.outputs.vpc_cidr_block
    },
  ]

  tags = local.tags
}

# terraform destroy할 때 고민해야함
# aws secretsmanager delete-secret --secret-id "redis-auth-token" --force
resource "aws_secretsmanager_secret" "redis_secret" {
  name        = "redis-auth-token"
  description = "Authentication token for Redis"
  
  tags = local.tags
}

resource "random_string" "redis_secret_value" {
  length           = 16  # 생성할 문자열의 길이
  special          = true # 특수 문자 포함 여부
  upper            = true # 대문자 포함 여부
  lower            = true # 소문자 포함 여부
  override_special = "!#$%&*" # 포함할 특수 문자를 지정할 수 있음 생략 가능 !@#$%&*
}

resource "aws_secretsmanager_secret_version" "redis_secret" {
  secret_id     = aws_secretsmanager_secret.redis_secret.id
  secret_string = random_string.redis_secret_value.result
}