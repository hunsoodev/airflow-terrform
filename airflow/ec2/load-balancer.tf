##################################################################
# Application Load Balancer
##################################################################

# AWS에서 load balancer 리소스를 생성
resource "aws_lb" "airflow_webserver_lb" {
  name               = "airflow-webserver-alb"
  internal           = false   # internal이 true일 경우, 로드 밸런서는 VPC 내부에서만 사용되는 내부 IP 주소를 갖게 됨
  load_balancer_type = "application"
  subnets            = data.terraform_remote_state.vpc.outputs.public_subnets
  security_groups    = [aws_security_group.airflow_webserver_lb_sg.id]

  enable_deletion_protection = false  # 로드 밸런서에 대한 삭제 보호 비활성화
}

# AWS에서 Application Load Balancer(ALB)용 타겟 그룹을 구성
# 특정 VPC 내에서 지정된 포트(여기서는 8080)와 프로토콜(HTTP)을 사용해 트래픽을 받을 준비가 된 리소스의 그룹
resource "aws_lb_target_group" "airflow_webserver_tg" {
  name        = "airflow-webserver-alb-tg"
  port        = 8080  # 타겟 그룹으로 전달되는 트래픽이 도달해야 하는 포트 번호 지정
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
}

# AWS의 Application Load Balancer(ALB)에 대한 리스너 설정을 정의
resource "aws_lb_listener" "airflow_webserver_listener" {
  load_balancer_arn = aws_lb.airflow_webserver_lb.arn  # 이 리스너가 연결된 로드 밸런서
  port              = "80"      # 리스너가 클라이언트의 요청을 받을 포트 번호 지정
  protocol          = "HTTP"    # 리스너가 사용할 프로토콜 지정
  default_action {
    type             = "forward"    # 리스너가 받은 요청을 특정 대상 그룹으로 전달하도록 지시
    target_group_arn = aws_lb_target_group.airflow_webserver_tg.arn
    # 요청을 전달할 대상 그룹 지정
  }
}

# 리소스를 사용하여 특정 EC2 인스턴스(또는 다른 지원되는 대상 유형)를 대상 그룹에 연결하여,
# 해당 대상 그룹이 트래픽을 해당 대상으로 전달할 수 있도록 함
resource "aws_lb_target_group_attachment" "airflow_webserver_tg_attachment" { # 대상 그룹 연결 생성
  availability_zone = "ap-northeast-2a"  # 연결할 때 사용할 가용 영역 지정
  target_group_arn  = aws_lb_target_group.airflow_webserver_tg.arn          # 연결에서 사용할 대상 그룹의 Amazon Resource Name(ARN)을 지정
  target_id         = aws_instance.airflow_webserver_scheduler.private_ip   # 특정 EC2 인스턴스의 프라이빗 IP 주소를 대상 ID로 사용
  port              = 8080   # 대상 트래픽을 수신할 포트 번호 지정
}

##################################################################
# Security Group
##################################################################

resource "aws_security_group" "airflow_webserver_lb_sg" {
  name        = "airflow-vpc/arflow-webserver-alb-sg"
  description = "Allow port 80 from everywhere and open 80 to Spoke VPC CIDRs"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "airflow-vpc/arflow-webserver-alb-sg"
  }
}