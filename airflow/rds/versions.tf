terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.33" # aws 프로바이더의 최소 버전 지정 (5.33 이상 요구)
    }
  }
}