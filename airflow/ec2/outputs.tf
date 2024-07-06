output "airflow_webserver_scheduler_id" {
  value = aws_instance.airflow_webserver_scheduler.id
}

# output "bastion_host_id" {
#   value = aws_instance.bastion_host.id
# }