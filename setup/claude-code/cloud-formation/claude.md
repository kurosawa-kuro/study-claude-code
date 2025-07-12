# AWS CloudFormation 開発ガイド

## 前提条件

- AWS SSO（AWS IAM Identity Center）経由でのアクセス
- AWS CLI v2 がインストール済み
- CloudFormation直接実行（CDK不使用）

## AWS SSO セットアップ

```bash
# SSO設定
aws configure sso

# SSOログイン
aws sso login --profile your-sso-profile

# プロファイル確認
aws sts get-caller-identity --profile your-sso-profile
```

## CloudFormation基本操作

### スタック作成

```bash
# テンプレート検証
aws cloudformation validate-template \
  --template-body file://template.yaml \
  --profile your-sso-profile

# スタック作成
aws cloudformation create-stack \
  --stack-name my-stack \
  --template-body file://template.yaml \
  --parameters file://parameters.json \
  --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
  --profile your-sso-profile

# 作成状況確認
aws cloudformation describe-stack-events \
  --stack-name my-stack \
  --profile your-sso-profile
```

### スタック更新

```bash
# チェンジセット作成
aws cloudformation create-change-set \
  --stack-name my-stack \
  --change-set-name my-changes \
  --template-body file://template.yaml \
  --parameters file://parameters.json \
  --capabilities CAPABILITY_IAM \
  --profile your-sso-profile

# チェンジセット確認
aws cloudformation describe-change-set \
  --stack-name my-stack \
  --change-set-name my-changes \
  --profile your-sso-profile

# チェンジセット実行
aws cloudformation execute-change-set \
  --stack-name my-stack \
  --change-set-name my-changes \
  --profile your-sso-profile
```

### スタック削除

```bash
# スタック削除
aws cloudformation delete-stack \
  --stack-name my-stack \
  --profile your-sso-profile

# 削除状況確認
aws cloudformation wait stack-delete-complete \
  --stack-name my-stack \
  --profile your-sso-profile
```

## テンプレートサンプル

### 基本的なVPC構成（template.yaml）

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: 'Basic VPC Configuration'

Parameters:
  EnvironmentName:
    Description: An environment name that is prefixed to resource names
    Type: String
    Default: dev

  VpcCIDR:
    Description: CIDR block for this VPC
    Type: String
    Default: 10.0.0.0/16

Resources:
  VPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: !Ref VpcCIDR
      EnableDnsHostnames: true
      EnableDnsSupport: true
      Tags:
        - Key: Name
          Value: !Sub ${EnvironmentName}-VPC

  InternetGateway:
    Type: AWS::EC2::InternetGateway
    Properties:
      Tags:
        - Key: Name
          Value: !Sub ${EnvironmentName}-IGW

  InternetGatewayAttachment:
    Type: AWS::EC2::VPCGatewayAttachment
    Properties:
      InternetGatewayId: !Ref InternetGateway
      VpcId: !Ref VPC

  PublicSubnet:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      AvailabilityZone: !Select [ 0, !GetAZs '' ]
      CidrBlock: 10.0.1.0/24
      MapPublicIpOnLaunch: true
      Tags:
        - Key: Name
          Value: !Sub ${EnvironmentName}-Public-Subnet

Outputs:
  VPC:
    Description: A reference to the created VPC
    Value: !Ref VPC
    Export:
      Name: !Sub ${EnvironmentName}-VPC-ID

  PublicSubnet:
    Description: A reference to the public subnet
    Value: !Ref PublicSubnet
    Export:
      Name: !Sub ${EnvironmentName}-PUBLIC-SUBNET
```

### パラメータファイル（parameters.json）

```json
[
  {
    "ParameterKey": "EnvironmentName",
    "ParameterValue": "production"
  },
  {
    "ParameterKey": "VpcCIDR",
    "ParameterValue": "10.1.0.0/16"
  }
]
```

## 便利なスクリプト

### デプロイスクリプト（deploy.sh）

```bash
#!/bin/bash
set -euo pipefail

# 変数設定
STACK_NAME="${1:-my-stack}"
TEMPLATE_FILE="template.yaml"
PARAMETERS_FILE="parameters.json"
PROFILE="${AWS_PROFILE:-your-sso-profile}"
REGION="${AWS_REGION:-ap-northeast-1}"

# 色付き出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Deploying stack: ${STACK_NAME}${NC}"

# テンプレート検証
echo "Validating template..."
aws cloudformation validate-template \
  --template-body file://${TEMPLATE_FILE} \
  --profile ${PROFILE} \
  --region ${REGION} > /dev/null

# スタック存在確認
if aws cloudformation describe-stacks \
  --stack-name ${STACK_NAME} \
  --profile ${PROFILE} \
  --region ${REGION} &> /dev/null; then
  ACTION="update"
else
  ACTION="create"
fi

# スタック作成/更新
if [ "$ACTION" = "create" ]; then
  echo -e "${GREEN}Creating new stack...${NC}"
  aws cloudformation create-stack \
    --stack-name ${STACK_NAME} \
    --template-body file://${TEMPLATE_FILE} \
    --parameters file://${PARAMETERS_FILE} \
    --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
    --profile ${PROFILE} \
    --region ${REGION}
  
  aws cloudformation wait stack-create-complete \
    --stack-name ${STACK_NAME} \
    --profile ${PROFILE} \
    --region ${REGION}
else
  echo -e "${GREEN}Updating existing stack...${NC}"
  CHANGE_SET_NAME="${STACK_NAME}-changeset-$(date +%s)"
  
  aws cloudformation create-change-set \
    --stack-name ${STACK_NAME} \
    --change-set-name ${CHANGE_SET_NAME} \
    --template-body file://${TEMPLATE_FILE} \
    --parameters file://${PARAMETERS_FILE} \
    --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
    --profile ${PROFILE} \
    --region ${REGION}
  
  aws cloudformation wait change-set-create-complete \
    --stack-name ${STACK_NAME} \
    --change-set-name ${CHANGE_SET_NAME} \
    --profile ${PROFILE} \
    --region ${REGION}
  
  # 変更内容表示
  aws cloudformation describe-change-set \
    --stack-name ${STACK_NAME} \
    --change-set-name ${CHANGE_SET_NAME} \
    --profile ${PROFILE} \
    --region ${REGION} \
    --query 'Changes[*].[Type, ResourceChange.Action, ResourceChange.LogicalResourceId, ResourceChange.ResourceType]' \
    --output table
  
  # 実行確認
  read -p "Execute change set? (y/N): " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    aws cloudformation execute-change-set \
      --stack-name ${STACK_NAME} \
      --change-set-name ${CHANGE_SET_NAME} \
      --profile ${PROFILE} \
      --region ${REGION}
    
    aws cloudformation wait stack-update-complete \
      --stack-name ${STACK_NAME} \
      --profile ${PROFILE} \
      --region ${REGION}
  else
    echo "Deleting change set..."
    aws cloudformation delete-change-set \
      --stack-name ${STACK_NAME} \
      --change-set-name ${CHANGE_SET_NAME} \
      --profile ${PROFILE} \
      --region ${REGION}
  fi
fi

echo -e "${GREEN}Deployment complete!${NC}"

# スタック出力表示
echo -e "\n${YELLOW}Stack outputs:${NC}"
aws cloudformation describe-stacks \
  --stack-name ${STACK_NAME} \
  --profile ${PROFILE} \
  --region ${REGION} \
  --query 'Stacks[0].Outputs[*].[OutputKey, OutputValue]' \
  --output table
```

### 使用方法

```bash
# 実行権限付与
chmod +x deploy.sh

# デプロイ実行
./deploy.sh my-stack

# プロファイルとリージョン指定
AWS_PROFILE=prod-profile AWS_REGION=us-east-1 ./deploy.sh prod-stack
```

## ベストプラクティス

### 1. テンプレート構成

```
project/
├── templates/
│   ├── main.yaml          # メインテンプレート
│   ├── network.yaml       # ネットワーク関連
│   ├── compute.yaml       # コンピュート関連
│   └── storage.yaml       # ストレージ関連
├── parameters/
│   ├── dev.json          # 開発環境パラメータ
│   ├── stg.json          # ステージング環境パラメータ
│   └── prod.json         # 本番環境パラメータ
├── scripts/
│   ├── deploy.sh         # デプロイスクリプト
│   └── validate.sh       # 検証スクリプト
└── README.md
```

### 2. ネストされたスタック

```yaml
Resources:
  NetworkStack:
    Type: AWS::CloudFormation::Stack
    Properties:
      TemplateURL: !Sub https://s3.amazonaws.com/${S3Bucket}/templates/network.yaml
      Parameters:
        EnvironmentName: !Ref EnvironmentName
      Tags:
        - Key: Name
          Value: !Sub ${EnvironmentName}-network-stack
```

### 3. 条件付きリソース

```yaml
Conditions:
  IsProduction: !Equals [ !Ref EnvironmentName, production ]

Resources:
  ProductionOnlyResource:
    Type: AWS::S3::Bucket
    Condition: IsProduction
    Properties:
      BucketName: !Sub ${AWS::StackName}-prod-backup
```

### 4. カスタムリソース

```yaml
Resources:
  CustomResourceFunction:
    Type: AWS::Lambda::Function
    Properties:
      Handler: index.handler
      Role: !GetAtt CustomResourceRole.Arn
      Code:
        ZipFile: |
          import cfnresponse
          import json
          
          def handler(event, context):
              try:
                  if event['RequestType'] == 'Create':
                      # カスタム処理
                      response_data = {'Message': 'Resource created'}
                      cfnresponse.send(event, context, cfnresponse.SUCCESS, response_data)
                  elif event['RequestType'] == 'Delete':
                      # クリーンアップ処理
                      cfnresponse.send(event, context, cfnresponse.SUCCESS, {})
              except Exception as e:
                  cfnresponse.send(event, context, cfnresponse.FAILED, {'Error': str(e)})
      Runtime: python3.9
```

## トラブルシューティング

### よくあるエラーと対処法

```bash
# スタック状態確認
aws cloudformation describe-stack-events \
  --stack-name my-stack \
  --profile your-sso-profile \
  --query 'StackEvents[?ResourceStatus==`CREATE_FAILED`].[LogicalResourceId, ResourceStatusReason]' \
  --output table

# ドリフト検出
aws cloudformation detect-stack-drift \
  --stack-name my-stack \
  --profile your-sso-profile

# ドリフト状態確認
aws cloudformation describe-stack-drift-detection-status \
  --stack-drift-detection-id <detection-id> \
  --profile your-sso-profile
```

### デバッグ用コマンド

```bash
# 全スタック一覧
aws cloudformation list-stacks \
  --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE \
  --profile your-sso-profile \
  --query 'StackSummaries[*].[StackName, StackStatus, CreationTime]' \
  --output table

# リソース一覧
aws cloudformation list-stack-resources \
  --stack-name my-stack \
  --profile your-sso-profile \
  --query 'StackResourceSummaries[*].[LogicalResourceId, ResourceType, ResourceStatus]' \
  --output table

# エクスポート値確認
aws cloudformation list-exports \
  --profile your-sso-profile \
  --query 'Exports[*].[Name, Value]' \
  --output table
```

## セキュリティベストプラクティス

### 1. IAMロール使用

```yaml
Resources:
  EC2Role:
    Type: AWS::IAM::Role
    Properties:
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Principal:
              Service: ec2.amazonaws.com
            Action: sts:AssumeRole
      ManagedPolicyArns:
        - arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
      Policies:
        - PolicyName: S3Access
          PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Effect: Allow
                Action:
                  - s3:GetObject
                  - s3:ListBucket
                Resource:
                  - !Sub arn:aws:s3:::${S3Bucket}/*
                  - !Sub arn:aws:s3:::${S3Bucket}
```

### 2. パラメータストア活用

```bash
# 機密情報の保存
aws ssm put-parameter \
  --name /myapp/prod/db-password \
  --value "your-secure-password" \
  --type SecureString \
  --profile your-sso-profile

# CloudFormationでの参照
```

```yaml
Parameters:
  DBPassword:
    Type: AWS::SSM::Parameter::Value<String>
    Default: /myapp/prod/db-password
    NoEcho: true
```

### 3. スタックポリシー

```json
{
  "Statement": [
    {
      "Effect": "Deny",
      "Principal": "*",
      "Action": "Update:Delete",
      "Resource": "LogicalResourceId/ProductionDatabase"
    },
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "Update:*",
      "Resource": "*"
    }
  ]
}
```

```bash
# スタックポリシー適用
aws cloudformation set-stack-policy \
  --stack-name my-stack \
  --stack-policy-body file://stack-policy.json \
  --profile your-sso-profile
```