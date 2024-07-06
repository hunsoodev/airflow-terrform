# airflow ssh 22포트 접속용도 -> session manager로 접속
# resource "aws_instance" "bastion_host" {
#   ami                         = data.aws_ami.ubuntu.id
#   subnet_id                   = data.terraform_remote_state.vpc.outputs.public_subnets[0]
#   # iam_instance_profile      = aws_iam_instance_profile.instance_profile.name
#   instance_type               = local.instance_type
#   # 퍼블릭 IP 주소 자동 할당 활성화
#   associate_public_ip_address = true
#   # user_data_replace_on_change = true
#   vpc_security_group_ids      = [aws_security_group.bastion_sg.id]

#   tags = {
#     Name      = "airflow-vpc/bastion-host"
#   }
# }

# Systems Manager Session Manager로 접속 (pwd: /var/snap/amazon-ssm-agent/7628)
# airflow web & sche 를 하나의 서버로 구석
resource "aws_instance" "airflow_webserver_scheduler" {
  ami                         = data.aws_ami.ubuntu.id
  subnet_id                   = data.terraform_remote_state.vpc.outputs.private_subnets[0]
  iam_instance_profile        = aws_iam_instance_profile.instance_profile.name

  instance_type               = local.instance_type
  # user_data_replace_on_change = true
  # user_data = file("${path.module}/init-script.sh")
  vpc_security_group_ids      = [aws_security_group.airflow_sg.id]

  tags = {
    Name      = "airflow-vpc/airflow-webserver-scheduler"
    component = "webserver & scheduler"
  }

  user_data = templatefile("${path.module}/init-web-sche.tpl", {
    db_secret_id    = local.database_secret_id,
    db_host         = local.database_endpoint,
    redis_secret_id = local.redis_secret_id,
    redis_host      = local.redis_endpoint,
  })
}


##################################################################
# Security Group
##################################################################

resource "aws_security_group" "airflow_sg" {
  name        = "airflow-sg"
  description = "Allow all traffic from VPCs inbound and all outbound"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [data.terraform_remote_state.vpc.outputs.vpc_cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "airflow-sg"
  }
}

# resource "aws_security_group" "bastion_sg" {
#   name        = "bastion-sg"
#   vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   tags = {
#     Name = "bastion-sg"
#   }
# }


# 다른 보안그룹의 특정 포트를 참조할 때 이런식으로 리소스를 생성해야함
# resource "aws_security_group_rule" "allow_from_source_to_target" {
#   type              = "ingress"
#   from_port         = 22
#   to_port           = 22
#   protocol          = "tcp"
#   source_security_group_id = aws_security_group.bastion_sg.id
#   security_group_id = aws_security_group.airflow_sg.id
# }
