output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.airflow_vpc.vpc_id
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = module.airflow_vpc.vpc_arn
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.airflow_vpc.vpc_cidr_block
}

################################################################################
# Internet Gateway
################################################################################

output "igw_id" {
  description = "The ID of the Internet Gateway"
  value       = module.airflow_vpc.igw_id
}

output "igw_arn" {
  description = "The ARN of the Internet Gateway"
  value       = module.airflow_vpc.igw_arn
}

################################################################################
# Publiс Subnets
################################################################################

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.airflow_vpc.public_subnets
}

output "public_subnet_arns" {
  description = "List of ARNs of public subnets"
  value       = module.airflow_vpc.public_subnet_arns
}

output "public_subnets_cidr_blocks" {
  description = "List of cidr_blocks of public subnets"
  value       = module.airflow_vpc.public_subnets_cidr_blocks
}

output "public_route_table_ids" {
  description = "List of IDs of public route tables"
  value       = module.airflow_vpc.public_route_table_ids
}

output "public_internet_gateway_route_id" {
  description = "ID of the internet gateway route"
  value       = module.airflow_vpc.public_internet_gateway_route_id
}

output "public_route_table_association_ids" {
  description = "List of IDs of the public route table association"
  value       = module.airflow_vpc.public_route_table_association_ids
}

#################################################################################
## Private Subnets
#################################################################################

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.airflow_vpc.private_subnets
}

output "private_subnet_arns" {
  description = "List of ARNs of private subnets"
  value       = module.airflow_vpc.private_subnet_arns
}

output "private_subnets_cidr_blocks" {
  description = "List of cidr_blocks of private subnets"
  value       = module.airflow_vpc.private_subnets_cidr_blocks
}

output "private_route_table_ids" {
  description = "List of IDs of private route tables"
  value       = module.airflow_vpc.private_route_table_ids
}

output "private_nat_gateway_route_ids" {
  description = "List of IDs of the private nat gateway route"
  value       = module.airflow_vpc.private_nat_gateway_route_ids
}

output "private_route_table_association_ids" {
  description = "List of IDs of the private route table association"
  value       = module.airflow_vpc.private_route_table_association_ids
}

#################################################################################
## Database Subnets
#################################################################################

output "database_subnets" {
  description = "List of IDs of database subnets"
  value       = module.airflow_vpc.database_subnets
}

output "database_subnet_arns" {
  description = "List of ARNs of database subnets"
  value       = module.airflow_vpc.database_subnet_arns
}

output "database_subnets_cidr_blocks" {
  description = "List of cidr_blocks of database subnets"
  value       = module.airflow_vpc.database_subnets_cidr_blocks
}

output "database_subnet_group" {
  description = "ID of database subnet group"
  value       = module.airflow_vpc.database_subnet_group
}

output "database_subnet_group_name" {
  description = "Name of database subnet group"
  value       = module.airflow_vpc.database_subnet_group_name
}

output "database_route_table_ids" {
  description = "List of IDs of database route tables"
  value = module.airflow_vpc.database_route_table_ids
}

output "database_nat_gateway_route_ids" {
  description = "List of IDs of the database nat gateway route"
  value       = module.airflow_vpc.database_nat_gateway_route_ids
}

output "database_route_table_association_ids" {
  description = "List of IDs of the database route table association"
  value       = module.airflow_vpc.database_route_table_association_ids
}

################################################################################
# Elasticache Subnets
################################################################################

output "elasticache_subnets" {
  description = "List of IDs of elasticache subnets"
  value       = module.airflow_vpc.elasticache_subnets
}

output "elasticache_subnet_arns" {
  description = "List of ARNs of elasticache subnets"
  value       = module.airflow_vpc.elasticache_subnet_arns
}

output "elasticache_subnets_cidr_blocks" {
  description = "List of cidr_blocks of elasticache subnets"
  value       = module.airflow_vpc.elasticache_subnets_cidr_blocks
}

output "elasticache_subnet_group" {
  description = "ID of elasticache subnet group"
  value       = module.airflow_vpc.elasticache_subnet_group
}

output "elasticache_subnet_group_name" {
  description = "Name of elasticache subnet group"
  value       = module.airflow_vpc.elasticache_subnet_group_name
}

output "elasticache_route_table_ids" {
  description = "List of IDs of elasticache route tables"
  value       = module.airflow_vpc.elasticache_route_table_ids
}

output "elasticache_route_table_association_ids" {
  description = "List of IDs of the elasticache route table association"
  value       = module.airflow_vpc.elasticache_route_table_association_ids
}
################################################################################
# Static values (arguments)
################################################################################

output "azs" {
  description = "A list of availability zones specified as argument to this module"
  value       = local.azs
}

output "name" {
  description = "The name of the VPC specified as argument to this module"
  value       = local.name
}