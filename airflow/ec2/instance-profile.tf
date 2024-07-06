# IAM 역할의 신뢰 정책 문서를 생성 
# -> 신뢰 정책은 IAM 역할을 "누가"(어떤 AWS 서비스나 계정)사용할 수 있는지 AWS 지시하는 것임
data "aws_iam_policy_document" "assume_role" {
  statement { # 선언문 정의
    effect = "Allow"

    principals {                            # 정책이 적용될 주체 정의
      type        = "Service"               # AWS 서비스, 다른 주체 유형으로는 AWS 계정, IAM 사용자, IAM 역할 등이 있음
      identifiers = ["ec2.amazonaws.com"]   # 정책이 적용될 AWS 서비스 지정
    }

    actions = ["sts:AssumeRole"]        # 정책에 의해 허용되는 작업을 나타냄
    # 지정된 역할을 가정하고 그 역할에 할당된 권한으로 AWS 서비스를 호출할 수 있게 함
    # EC2 인스턴스가 해당 역할을 가정할 수 있도록 설정할 수 있음
    # 한 AWS IAM 사용자나 서비스가 다른 IAM 역할을 "가정"(assume)할 수 있게 해주는 작업
  }
}

# AWS IAM 역할을 생성하는 예제
resource "aws_iam_role" "instance_role" {
  name               = "airflow-instance-role"  # IAM 역할의 이름
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# AWS IAM 인스턴스 프로필을 생성하는 부분
# IAM 인스턴스 프로필은 AWS 서비스에 대한 액세스 권한을 EC2 인스턴스에 부여하는 데 사용됨 
resource "aws_iam_instance_profile" "instance_profile" {
  name = "airflow-instance-profile"
  role = aws_iam_role.instance_role.name

  lifecycle {
    create_before_destroy = true
  }
}

# AWS IAM 역할에 기존 IAM 정책을 연결하는 작업을 정의
resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {
  role       = aws_iam_role.instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  # AmazonSSMManagedInstanceCore라는 관리형 IAM 정책을 특정 IAM 역할에 연결
}

# IAM 정책 문서를 생성하는 예제
# 실제 AWS 리소스를 생성하지 않고, IAM 정책 문서를 정의하는 JSON 형식의 문자열을 반환함
data "aws_iam_policy_document" "get_secret_policy" {
  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    # 정책을 부여받은 IAM 엔티티가 AWS Secrets Manager에 저장된 비밀의 값을 가져올 수 있도록 허용
    resources = ["*"]
  }
}

# aws_iam_plicy_document에서 만든 정책 문서를 바탕으로 -> 실제 IMA 정책을 생성하는 aws_iam_policy 리소스
# IAM 정책 리소스를 생성
resource "aws_iam_policy" "get_secret_policy" {
  name        = "get-secret-policy"
  description = "get-secret-policy"
  policy      = data.aws_iam_policy_document.get_secret_policy.json
}

# IAM 역할에 IAM 정책을 연결하는 작업 수행
resource "aws_iam_role_policy_attachment" "get_secret_policy_attachment" {
  role       = aws_iam_role.instance_role.name
  policy_arn = aws_iam_policy.get_secret_policy.arn
}

# s3 정책 여러개가 묶여있는(1개 이상) iam 정책(역할) 생성
resource "aws_iam_policy" "s3_access" {
  name        = "s3AccessPolicy"
  description = "Policy for allowing EC2 instance to access specific S3 Bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Effect   = "Allow"
        "Resource": [
				"arn:aws:s3:::de-2-1-bucket",
				"arn:aws:s3:::de-2-1-bucket/*"
			]
      },
    ]
  })
}

#  IAM에 정책 연결
resource "aws_iam_role_policy_attachment" "s3_access_attachment" {
  role       = aws_iam_role.instance_role.name
  policy_arn = aws_iam_policy.s3_access.arn
}

