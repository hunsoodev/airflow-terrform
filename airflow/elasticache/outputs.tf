################################################################################
# ElastiCache
################################################################################

output "cluster_arn" {
  description = "The ARN of the created ElastiCache Cluster."
  value       = aws_elasticache_cluster.airflow_celery_broker.arn
}

output "primary_endpoint_address" {
  description = "(Redis only) Address of the endpoint for the primary node in the replication group, if the cluster mode is disabled."
  value       = aws_elasticache_replication_group.airflow_celery_broker.primary_endpoint_address
}

output "reader_endpoint_address" {
  description = "(Redis only) Address of the endpoint for the reader node in the replication group, if the cluster mode is disabled."
  value       = aws_elasticache_replication_group.airflow_celery_broker.reader_endpoint_address
}

################################################################################
# Secret
################################################################################

output "secret_arn" {
  description = "The ARN of the secret"
  value       = try(aws_secretsmanager_secret.redis_secret.arn, null)
}

output "secret_id" {
  description = "The ID of the secret"
  value       = try(aws_secretsmanager_secret.redis_secret.id, null)
}

################################################################################
# Version
################################################################################

output "secret_version_id" {
  description = "The unique identifier of the version of the secret"
  value       = try(aws_secretsmanager_secret_version.redis_secret.version_id, null)
}