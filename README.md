# DEV PROJECT

인프라스트럭처(infrastructure) 형상 관리를 위한 저장소입니다. 

## Note

`export AWS_PROFILE="YOUR_PROFILE"` 명령어로  `~/.aws/credentials`에 저장되어 있는 AWS profile을 환경 변수로 지정하여 사용하거나, 아래와 같이 `provider` 부분에서 지정하여 사용하면 됩니다.

```hcl
provider "aws" {
  region                  = "ap-northeast-2"
  skip_metadata_api_check = true
  profile                 = "YOUR_PROFILE"
}
```
구성 요소 변경시 부작용(side effect) 최소화를 위해 각 경로 별로 다른 `remote backend`를 사용하고 있습니다. VPC -> RDS 혹은 ElastiCache -> EC2 순서로 생성해주세요. 제거할 때는 반대로 하면 됩니다.