# AWS CloudFormation 開発ガイド

## 目次

1. [クイックスタート](#クイックスタート)
2. [環境セットアップ](#環境セットアップ)
3. [基本的な開発ワークフロー](#基本的な開発ワークフロー)
4. [テンプレートとパラメータ](#テンプレートとパラメータ)
5. [自動化スクリプト](#自動化スクリプト)
6. [ベストプラクティス](#ベストプラクティス)
7. [トラブルシューティング](#トラブルシューティング)
8. [セキュリティ](#セキュリティ)

## クイックスタート

### 5分で始めるCloudFormation

```bash
# 1. SSO設定（初回のみ）
aws configure sso

# 2. SSOログイン
aws sso login --profile your-sso-profile

# 3. テンプレート検証
aws cloudformation validate-template \
  --template-body file://template.yaml \
  --profile your-sso-profile

# 4. スタック作成
aws cloudformation create-stack \
  --stack-name my-first-stack \
  --template-body file://template.yaml \
  --profile your-sso-profile

# 5. 作成状況確認
aws cloudformation describe-stack-events \
  --stack-name my-first-stack \
  --profile your-sso-profile
```

## 環境セットアップ

### 前提条件

- AWS SSO（AWS IAM Identity Center）経由でのアクセス
- AWS CLI v2 がインストール済み
- CloudFormation直接実行（CDK不使用）

### AWS SSO設定

```bash
# SSO設定
aws configure sso

# SSOログイン
aws sso login --profile your-sso-profile

# プロファイル確認
aws sts get-caller-identity --profile your-sso-profile
```

### プロジェクト構成の推奨

```
cloudformation-project/
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
│   ├── validate.sh       # 検証スクリプト
│   └── cleanup.sh        # クリーンアップスクリプト
├── policies/
│   └── stack-policy.json # スタックポリシー
└── README.md
```

## 基本的な開発ワークフロー

### 1. 開発フェーズ

```bash
# テンプレート検証
aws cloudformation validate-template \
  --template-body file://templates/main.yaml \
  --profile your-sso-profile

# 開発環境デプロイ
aws cloudformation create-stack \
  --stack-name myapp-dev \
  --template-body file://templates/main.yaml \
  --parameters file://parameters/dev.json \
  --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
  --profile your-sso-profile
```

### 2. 更新フェーズ

```bash
# チェンジセット作成
aws cloudformation create-change-set \
  --stack-name myapp-dev \
  --change-set-name update-$(date +%s) \
  --template-body file://templates/main.yaml \
  --parameters file://parameters/dev.json \
  --capabilities CAPABILITY_IAM \
  --profile your-sso-profile

# 変更内容確認
aws cloudformation describe-change-set \
  --stack-name myapp-dev \
  --change-set-name update-$(date +%s) \
  --profile your-sso-profile \
  --query 'Changes[*].[Type, ResourceChange.Action, ResourceChange.LogicalResourceId]' \
  --output table

# チェンジセット実行
aws cloudformation execute-change-set \
  --stack-name myapp-dev \
  --change-set-name update-$(date +%s) \
  --profile your-sso-profile
```

### 3. 本番デプロイフェーズ

```bash
# 本番環境デプロイ（慎重に）
aws cloudformation create-stack \
  --stack-name myapp-prod \
  --template-body file://templates/main.yaml \
  --parameters file://parameters/prod.json \
  --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
  --stack-policy-body file://policies/stack-policy.json \
  --profile your-sso-profile

# デプロイ完了待機
aws cloudformation wait stack-create-complete \
  --stack-name myapp-prod \
  --profile your-sso-profile
```

### 4. クリーンアップフェーズ

```bash
# 開発環境削除
aws cloudformation delete-stack \
  --stack-name myapp-dev \
  --profile your-sso-profile

# 削除完了確認
aws cloudformation wait stack-delete-complete \
  --stack-name myapp-dev \
  --profile your-sso-profile
```

## テンプレートとパラメータ

### 実践的なVPCテンプレート（templates/network.yaml）

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: 'Production-ready VPC with public/private subnets'

Parameters:
  EnvironmentName:
    Description: Environment name prefix
    Type: String
    AllowedValues: [dev, stg, prod]
    Default: dev

  VpcCIDR:
    Description: CIDR block for VPC
    Type: String
    Default: 10.0.0.0/16
    AllowedPattern: ^([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{1,2}$

  EnableVPCFlowLogs:
    Description: Enable VPC Flow Logs
    Type: String
    Default: 'true'
    AllowedValues: ['true', 'false']

Conditions:
  IsProduction: !Equals [!Ref EnvironmentName, prod]
  EnableFlowLogs: !Equals [!Ref EnableVPCFlowLogs, 'true']

Resources:
  VPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: !Ref VpcCIDR
      EnableDnsHostnames: true
      EnableDnsSupport: true
      Tags:
        - Key: Name
          Value: !Sub ${EnvironmentName}-vpc
        - Key: Environment
          Value: !Ref EnvironmentName

  # インターネットゲートウェイ
  InternetGateway:
    Type: AWS::EC2::InternetGateway
    Properties:
      Tags:
        - Key: Name
          Value: !Sub ${EnvironmentName}-igw

  InternetGatewayAttachment:
    Type: AWS::EC2::VPCGatewayAttachment
    Properties:
      InternetGatewayId: !Ref InternetGateway
      VpcId: !Ref VPC

  # パブリックサブネット
  PublicSubnet1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      AvailabilityZone: !Select [0, !GetAZs '']
      CidrBlock: !Sub 
        - '${VpcCIDR_Prefix}.1.0/24'
        - VpcCIDR_Prefix: !Select [0, !Split ['.', !Select [0, !Split ['/', !Ref VpcCIDR]]]]
      MapPublicIpOnLaunch: true
      Tags:
        - Key: Name
          Value: !Sub ${EnvironmentName}-public-subnet-1

  PublicSubnet2:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      AvailabilityZone: !Select [1, !GetAZs '']
      CidrBlock: !Sub 
        - '${VpcCIDR_Prefix}.2.0/24'
        - VpcCIDR_Prefix: !Select [0, !Split ['.', !Select [0, !Split ['/', !Ref VpcCIDR]]]]
      MapPublicIpOnLaunch: true
      Tags:
        - Key: Name
          Value: !Sub ${EnvironmentName}-public-subnet-2

  # プライベートサブネット
  PrivateSubnet1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      AvailabilityZone: !Select [0, !GetAZs '']
      CidrBlock: !Sub 
        - '${VpcCIDR_Prefix}.11.0/24'
        - VpcCIDR_Prefix: !Select [0, !Split ['.', !Select [0, !Split ['/', !Ref VpcCIDR]]]]
      Tags:
        - Key: Name
          Value: !Sub ${EnvironmentName}-private-subnet-1

  PrivateSubnet2:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      AvailabilityZone: !Select [1, !GetAZs '']
      CidrBlock: !Sub 
        - '${VpcCIDR_Prefix}.12.0/24'
        - VpcCIDR_Prefix: !Select [0, !Split ['.', !Select [0, !Split ['/', !Ref VpcCIDR]]]]
      Tags:
        - Key: Name
          Value: !Sub ${EnvironmentName}-private-subnet-2

  # NAT Gateway（本番環境のみ）
  NatGateway1EIP:
    Type: AWS::EC2::EIP
    Condition: IsProduction
    DependsOn: InternetGatewayAttachment
    Properties:
      Domain: vpc
      Tags:
        - Key: Name
          Value: !Sub ${EnvironmentName}-nat-eip-1

  NatGateway1:
    Type: AWS::EC2::NatGateway
    Condition: IsProduction
    Properties:
      AllocationId: !GetAtt NatGateway1EIP.AllocationId
      SubnetId: !Ref PublicSubnet1
      Tags:
        - Key: Name
          Value: !Sub ${EnvironmentName}-nat-1

  # ルートテーブル
  PublicRouteTable:
    Type: AWS::EC2::RouteTable
    Properties:
      VpcId: !Ref VPC
      Tags:
        - Key: Name
          Value: !Sub ${EnvironmentName}-public-routes

  DefaultPublicRoute:
    Type: AWS::EC2::Route
    DependsOn: InternetGatewayAttachment
    Properties:
      RouteTableId: !Ref PublicRouteTable
      DestinationCidrBlock: 0.0.0.0/0
      GatewayId: !Ref InternetGateway

  PublicSubnet1RouteTableAssociation:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      RouteTableId: !Ref PublicRouteTable
      SubnetId: !Ref PublicSubnet1

  PublicSubnet2RouteTableAssociation:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      RouteTableId: !Ref PublicRouteTable
      SubnetId: !Ref PublicSubnet2

  PrivateRouteTable1:
    Type: AWS::EC2::RouteTable
    Properties:
      VpcId: !Ref VPC
      Tags:
        - Key: Name
          Value: !Sub ${EnvironmentName}-private-routes-1

  DefaultPrivateRoute1:
    Type: AWS::EC2::Route
    Condition: IsProduction
    Properties:
      RouteTableId: !Ref PrivateRouteTable1
      DestinationCidrBlock: 0.0.0.0/0
      NatGatewayId: !Ref NatGateway1

  PrivateSubnet1RouteTableAssociation:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      RouteTableId: !Ref PrivateRouteTable1
      SubnetId: !Ref PrivateSubnet1

  PrivateSubnet2RouteTableAssociation:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      RouteTableId: !Ref PrivateRouteTable1
      SubnetId: !Ref PrivateSubnet2

  # VPC Flow Logs
  VPCFlowLogRole:
    Type: AWS::IAM::Role
    Condition: EnableFlowLogs
    Properties:
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Principal:
              Service: vpc-flow-logs.amazonaws.com
            Action: sts:AssumeRole
      Policies:
        - PolicyName: CloudWatchLogsPolicy
          PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Effect: Allow
                Action:
                  - logs:CreateLogGroup
                  - logs:CreateLogStream
                  - logs:PutLogEvents
                  - logs:DescribeLogGroups
                  - logs:DescribeLogStreams
                Resource: '*'

  VPCFlowLog:
    Type: AWS::EC2::FlowLog
    Condition: EnableFlowLogs
    Properties:
      ResourceType: VPC
      ResourceId: !Ref VPC
      TrafficType: ALL
      LogDestinationType: cloud-watch-logs
      LogGroupName: !Sub /aws/vpc/flowlogs/${EnvironmentName}
      DeliverLogsPermissionArn: !GetAtt VPCFlowLogRole.Arn
      Tags:
        - Key: Name
          Value: !Sub ${EnvironmentName}-vpc-flowlog

Outputs:
  VPC:
    Description: VPC ID
    Value: !Ref VPC
    Export:
      Name: !Sub ${EnvironmentName}-VPC-ID

  PublicSubnets:
    Description: Public subnets
    Value: !Join [',', [!Ref PublicSubnet1, !Ref PublicSubnet2]]
    Export:
      Name: !Sub ${EnvironmentName}-PUBLIC-SUBNETS

  PrivateSubnets:
    Description: Private subnets
    Value: !Join [',', [!Ref PrivateSubnet1, !Ref PrivateSubnet2]]
    Export:
      Name: !Sub ${EnvironmentName}-PRIVATE-SUBNETS

  PublicSubnet1:
    Description: Public subnet 1
    Value: !Ref PublicSubnet1
    Export:
      Name: !Sub ${EnvironmentName}-PUBLIC-SUBNET-1

  PublicSubnet2:
    Description: Public subnet 2
    Value: !Ref PublicSubnet2
    Export:
      Name: !Sub ${EnvironmentName}-PUBLIC-SUBNET-2

  PrivateSubnet1:
    Description: Private subnet 1
    Value: !Ref PrivateSubnet1
    Export:
      Name: !Sub ${EnvironmentName}-PRIVATE-SUBNET-1

  PrivateSubnet2:
    Description: Private subnet 2
    Value: !Ref PrivateSubnet2
    Export:
      Name: !Sub ${EnvironmentName}-PRIVATE-SUBNET-2
```

### 環境別パラメータファイル

#### parameters/dev.json
```json
[
  {
    "ParameterKey": "EnvironmentName",
    "ParameterValue": "dev"
  },
  {
    "ParameterKey": "VpcCIDR",
    "ParameterValue": "10.0.0.0/16"
  },
  {
    "ParameterKey": "EnableVPCFlowLogs",
    "ParameterValue": "false"
  }
]
```

#### parameters/prod.json
```json
[
  {
    "ParameterKey": "EnvironmentName",
    "ParameterValue": "prod"
  },
  {
    "ParameterKey": "VpcCIDR",
    "ParameterValue": "10.1.0.0/16"
  },
  {
    "ParameterKey": "EnableVPCFlowLogs",
    "ParameterValue": "true"
  }
]
```

## 自動化スクリプト

### 高機能デプロイスクリプト（scripts/deploy.sh）

```bash
#!/bin/bash
set -euo pipefail

# スクリプト設定
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# デフォルト値
DEFAULT_TEMPLATE="templates/main.yaml"
DEFAULT_PROFILE="default"
DEFAULT_REGION="ap-northeast-1"

# 使用方法表示
usage() {
    cat << EOF
Usage: $0 [OPTIONS] STACK_NAME ENVIRONMENT

Options:
    -t, --template FILE     CloudFormation template file (default: $DEFAULT_TEMPLATE)
    -p, --profile PROFILE   AWS profile (default: $DEFAULT_PROFILE)
    -r, --region REGION     AWS region (default: $DEFAULT_REGION)
    -w, --wait              Wait for stack operation to complete
    -d, --dry-run           Show what would be deployed without executing
    -h, --help              Show this help message

Environment:
    dev, stg, prod

Examples:
    $0 myapp-dev dev
    $0 -t templates/network.yaml -p prod-profile myapp-prod prod
    $0 --dry-run myapp-stg stg
EOF
}

# 色付き出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# パラメータ解析
TEMPLATE="$DEFAULT_TEMPLATE"
PROFILE="$DEFAULT_PROFILE"
REGION="$DEFAULT_REGION"
WAIT=false
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--template)
            TEMPLATE="$2"
            shift 2
            ;;
        -p|--profile)
            PROFILE="$2"
            shift 2
            ;;
        -r|--region)
            REGION="$2"
            shift 2
            ;;
        -w|--wait)
            WAIT=true
            shift
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        -*)
            log_error "Unknown option: $1"
            usage
            exit 1
            ;;
        *)
            break
            ;;
    esac
done

# 必須パラメータチェック
if [[ $# -lt 2 ]]; then
    log_error "Missing required arguments"
    usage
    exit 1
fi

STACK_NAME="$1"
ENVIRONMENT="$2"

# 環境チェック
if [[ ! "$ENVIRONMENT" =~ ^(dev|stg|prod)$ ]]; then
    log_error "Invalid environment: $ENVIRONMENT. Must be dev, stg, or prod"
    exit 1
fi

# ファイル存在チェック
TEMPLATE_PATH="$PROJECT_DIR/$TEMPLATE"
PARAMETERS_PATH="$PROJECT_DIR/parameters/$ENVIRONMENT.json"

if [[ ! -f "$TEMPLATE_PATH" ]]; then
    log_error "Template file not found: $TEMPLATE_PATH"
    exit 1
fi

if [[ ! -f "$PARAMETERS_PATH" ]]; then
    log_error "Parameters file not found: $PARAMETERS_PATH"
    exit 1
fi

# AWS CLI設定確認
if ! aws sts get-caller-identity --profile "$PROFILE" --region "$REGION" >/dev/null 2>&1; then
    log_error "AWS CLI not configured or invalid profile/region"
    log_info "Try: aws sso login --profile $PROFILE"
    exit 1
fi

log_info "Deploying CloudFormation stack"
log_info "Stack Name: $STACK_NAME"
log_info "Environment: $ENVIRONMENT"
log_info "Template: $TEMPLATE_PATH"
log_info "Parameters: $PARAMETERS_PATH"
log_info "Profile: $PROFILE"
log_info "Region: $REGION"

# DRY RUN モード
if [[ "$DRY_RUN" == true ]]; then
    log_warning "DRY RUN MODE - No actual deployment will occur"
    
    log_info "Validating template..."
    aws cloudformation validate-template \
        --template-body "file://$TEMPLATE_PATH" \
        --profile "$PROFILE" \
        --region "$REGION"
    
    log_success "Template validation successful"
    log_info "Would deploy with the above configuration"
    exit 0
fi

# テンプレート検証
log_info "Validating template..."
if ! aws cloudformation validate-template \
    --template-body "file://$TEMPLATE_PATH" \
    --profile "$PROFILE" \
    --region "$REGION" >/dev/null; then
    log_error "Template validation failed"
    exit 1
fi
log_success "Template validation successful"

# スタック存在確認
ACTION="create"
if aws cloudformation describe-stacks \
    --stack-name "$STACK_NAME" \
    --profile "$PROFILE" \
    --region "$REGION" >/dev/null 2>&1; then
    ACTION="update"
fi

# 本番環境確認
if [[ "$ENVIRONMENT" == "prod" && "$ACTION" == "create" ]]; then
    log_warning "You are about to create a PRODUCTION stack!"
    read -p "Are you sure you want to continue? (type 'yes' to confirm): " -r
    if [[ ! "$REPLY" == "yes" ]]; then
        log_info "Deployment cancelled"
        exit 0
    fi
fi

# デプロイ実行
case "$ACTION" in
    "create")
        log_info "Creating new stack..."
        COMMAND=(
            aws cloudformation create-stack
            --stack-name "$STACK_NAME"
            --template-body "file://$TEMPLATE_PATH"
            --parameters "file://$PARAMETERS_PATH"
            --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM
            --profile "$PROFILE"
            --region "$REGION"
        )
        
        # 本番環境はスタックポリシー適用
        if [[ "$ENVIRONMENT" == "prod" && -f "$PROJECT_DIR/policies/stack-policy.json" ]]; then
            COMMAND+=(--stack-policy-body "file://$PROJECT_DIR/policies/stack-policy.json")
        fi
        
        "${COMMAND[@]}"
        
        if [[ "$WAIT" == true ]]; then
            log_info "Waiting for stack creation to complete..."
            aws cloudformation wait stack-create-complete \
                --stack-name "$STACK_NAME" \
                --profile "$PROFILE" \
                --region "$REGION"
        fi
        ;;
        
    "update")
        log_info "Updating existing stack..."
        CHANGE_SET_NAME="changeset-$(date +%s)"
        
        aws cloudformation create-change-set \
            --stack-name "$STACK_NAME" \
            --change-set-name "$CHANGE_SET_NAME" \
            --template-body "file://$TEMPLATE_PATH" \
            --parameters "file://$PARAMETERS_PATH" \
            --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
            --profile "$PROFILE" \
            --region "$REGION"
        
        log_info "Waiting for change set creation..."
        aws cloudformation wait change-set-create-complete \
            --stack-name "$STACK_NAME" \
            --change-set-name "$CHANGE_SET_NAME" \
            --profile "$PROFILE" \
            --region "$REGION"
        
        # 変更内容表示
        log_info "Change set summary:"
        aws cloudformation describe-change-set \
            --stack-name "$STACK_NAME" \
            --change-set-name "$CHANGE_SET_NAME" \
            --profile "$PROFILE" \
            --region "$REGION" \
            --query 'Changes[*].[Type, ResourceChange.Action, ResourceChange.LogicalResourceId, ResourceChange.ResourceType]' \
            --output table
        
        # 実行確認
        if [[ "$ENVIRONMENT" == "prod" ]]; then
            log_warning "You are about to update a PRODUCTION stack!"
        fi
        read -p "Execute change set? (y/N): " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            aws cloudformation execute-change-set \
                --stack-name "$STACK_NAME" \
                --change-set-name "$CHANGE_SET_NAME" \
                --profile "$PROFILE" \
                --region "$REGION"
            
            if [[ "$WAIT" == true ]]; then
                log_info "Waiting for stack update to complete..."
                aws cloudformation wait stack-update-complete \
                    --stack-name "$STACK_NAME" \
                    --profile "$PROFILE" \
                    --region "$REGION"
            fi
        else
            log_info "Deleting change set..."
            aws cloudformation delete-change-set \
                --stack-name "$STACK_NAME" \
                --change-set-name "$CHANGE_SET_NAME" \
                --profile "$PROFILE" \
                --region "$REGION"
            log_info "Change set deleted"
            exit 0
        fi
        ;;
esac

log_success "Deployment completed successfully!"

# スタック出力表示
if aws cloudformation describe-stacks \
    --stack-name "$STACK_NAME" \
    --profile "$PROFILE" \
    --region "$REGION" \
    --query 'Stacks[0].Outputs' >/dev/null 2>&1; then
    
    log_info "Stack outputs:"
    aws cloudformation describe-stacks \
        --stack-name "$STACK_NAME" \
        --profile "$PROFILE" \
        --region "$REGION" \
        --query 'Stacks[0].Outputs[*].[OutputKey, OutputValue, Description]' \
        --output table
fi
```

### 検証スクリプト（scripts/validate.sh）

```bash
#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# 色付き出力
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_success() { echo -e "${GREEN}✓${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1"; }
log_warning() { echo -e "${YELLOW}!${NC} $1"; }

errors=0

echo "Validating CloudFormation templates..."

# テンプレートファイル検索と検証
find "$PROJECT_DIR/templates" -name "*.yaml" -o -name "*.yml" -o -name "*.json" | while read -r template; do
    echo -n "Validating $(basename "$template")... "
    
    if aws cloudformation validate-template --template-body "file://$template" >/dev/null 2>&1; then
        log_success "Valid"
    else
        log_error "Invalid"
        ((errors++))
    fi
done

# パラメータファイル検証
echo -e "\nValidating parameter files..."
for env in dev stg prod; do
    param_file="$PROJECT_DIR/parameters/$env.json"
    if [[ -f "$param_file" ]]; then
        echo -n "Validating $env.json... "
        if jq empty "$param_file" 2>/dev/null; then
            log_success "Valid JSON"
        else
            log_error "Invalid JSON"
            ((errors++))
        fi
    else
        log_warning "Parameter file not found: $param_file"
    fi
done

# スタックポリシー検証
if [[ -f "$PROJECT_DIR/policies/stack-policy.json" ]]; then
    echo -n "Validating stack policy... "
    if jq empty "$PROJECT_DIR/policies/stack-policy.json" 2>/dev/null; then
        log_success "Valid JSON"
    else
        log_error "Invalid JSON"
        ((errors++))
    fi
fi

echo -e "\nValidation complete!"
if [[ $errors -eq 0 ]]; then
    log_success "All files are valid"
    exit 0
else
    log_error "$errors validation errors found"
    exit 1
fi
```

## ベストプラクティス

### 1. テンプレート設計原則

#### 再利用可能な設計
```yaml
# ❌ ハードコード
Resources:
  MyBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: my-app-bucket-prod

# ✅ パラメータ化
Parameters:
  Environment:
    Type: String
  AppName:
    Type: String

Resources:
  MyBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: !Sub ${AppName}-bucket-${Environment}
```

#### 条件付きリソース
```yaml
Conditions:
  IsProduction: !Equals [!Ref Environment, prod]
  IsDevOrStg: !Or [!Equals [!Ref Environment, dev], !Equals [!Ref Environment, stg]]

Resources:
  # 本番環境のみでバックアップ設定
  BackupBucket:
    Type: AWS::S3::Bucket
    Condition: IsProduction
    Properties:
      VersioningConfiguration:
        Status: Enabled
      
  # 開発・ステージング環境は削除ポリシー
  TempBucket:
    Type: AWS::S3::Bucket
    Condition: IsDevOrStg
    DeletionPolicy: Delete
```

### 2. ネストされたスタック活用

#### メインテンプレート
```yaml
Resources:
  NetworkStack:
    Type: AWS::CloudFormation::Stack
    Properties:
      TemplateURL: !Sub 
        - https://${S3Bucket}.s3.${AWS::Region}.amazonaws.com/templates/network.yaml
        - S3Bucket: !Ref TemplatesBucket
      Parameters:
        EnvironmentName: !Ref EnvironmentName
        VpcCIDR: !Ref VpcCIDR
      Tags:
        - Key: StackType
          Value: Network

  ComputeStack:
    Type: AWS::CloudFormation::Stack
    DependsOn: NetworkStack
    Properties:
      TemplateURL: !Sub 
        - https://${S3Bucket}.s3.${AWS::Region}.amazonaws.com/templates/compute.yaml
        - S3Bucket: !Ref TemplatesBucket
      Parameters:
        EnvironmentName: !Ref EnvironmentName
        VpcId: !GetAtt NetworkStack.Outputs.VpcId
        PrivateSubnetIds: !GetAtt NetworkStack.Outputs.PrivateSubnets
```

### 3. カスタムリソースパターン

```yaml
Resources:
  CustomResourceFunction:
    Type: AWS::Lambda::Function
    Properties:
      FunctionName: !Sub ${AWS::StackName}-custom-resource
      Handler: index.handler
      Role: !GetAtt CustomResourceRole.Arn
      Code:
        ZipFile: |
          import json
          import boto3
          import cfnresponse
          
          def handler(event, context):
              try:
                  request_type = event['RequestType']
                  properties = event['ResourceProperties']
                  
                  if request_type == 'Create':
                      # リソース作成処理
                      result = create_resource(properties)
                      response_data = {'ResourceId': result['id']}
                      physical_id = result['id']
                      
                  elif request_type == 'Update':
                      # リソース更新処理
                      physical_id = event['PhysicalResourceId']
                      result = update_resource(physical_id, properties)
                      response_data = {'ResourceId': physical_id}
                      
                  elif request_type == 'Delete':
                      # リソース削除処理
                      physical_id = event['PhysicalResourceId']
                      delete_resource(physical_id)
                      response_data = {}
                  
                  cfnresponse.send(event, context, cfnresponse.SUCCESS, 
                                 response_data, physical_id)
                                 
              except Exception as e:
                  print(f'Error: {str(e)}')
                  cfnresponse.send(event, context, cfnresponse.FAILED, 
                                 {'Error': str(e)})
          
          def create_resource(properties):
              # 実装
              pass
              
          def update_resource(resource_id, properties):
              # 実装
              pass
              
          def delete_resource(resource_id):
              # 実装
              pass
      Runtime: python3.9
      Timeout: 300

  CustomResource:
    Type: AWS::CloudFormation::CustomResource
    Properties:
      ServiceToken: !GetAtt CustomResourceFunction.Arn
      CustomProperty1: !Ref SomeParameter
      CustomProperty2: !Ref AnotherParameter
```

## トラブルシューティング

### 1. 一般的なデバッグ手順

```bash
# スタック状態確認
aws cloudformation describe-stacks \
  --stack-name my-stack \
  --profile your-profile \
  --query 'Stacks[0].[StackName, StackStatus, StackStatusReason]' \
  --output table

# 失敗したリソース特定
aws cloudformation describe-stack-events \
  --stack-name my-stack \
  --profile your-profile \
  --query 'StackEvents[?ResourceStatus==`CREATE_FAILED` || ResourceStatus==`UPDATE_FAILED`].[LogicalResourceId, ResourceType, ResourceStatusReason]' \
  --output table

# スタックドリフト検出
aws cloudformation detect-stack-drift \
  --stack-name my-stack \
  --profile your-profile

# ドリフト結果確認
DRIFT_ID=$(aws cloudformation detect-stack-drift \
  --stack-name my-stack \
  --profile your-profile \
  --query 'StackDriftDetectionId' \
  --output text)

aws cloudformation describe-stack-drift-detection-status \
  --stack-drift-detection-id $DRIFT_ID \
  --profile your-profile
```

### 2. よくあるエラーと対処法

#### リソース作成失敗
```bash
# エラー詳細確認
aws cloudformation describe-stack-resources \
  --stack-name my-stack \
  --logical-resource-id FailedResourceName \
  --profile your-profile

# CloudWatch Logsでさらなる詳細確認（Lambda関数の場合）
aws logs describe-log-groups \
  --log-group-name-prefix /aws/lambda/my-function \
  --profile your-profile
```

#### 依存関係エラー
```yaml
# ❌ 暗黙的依存関係
Resources:
  EC2Instance:
    Type: AWS::EC2::Instance
    Properties:
      SubnetId: !Ref Subnet  # Subnetが先に作成される保証なし

# ✅ 明示的依存関係
Resources:
  EC2Instance:
    Type: AWS::EC2::Instance
    DependsOn: 
      - Subnet
      - SecurityGroup
    Properties:
      SubnetId: !Ref Subnet
      SecurityGroupIds:
        - !Ref SecurityGroup
```

#### 更新失敗時の復旧
```bash
# 更新失敗時の継続
aws cloudformation continue-update-rollback \
  --stack-name my-stack \
  --profile your-profile

# スタックが完全に壊れた場合の強制削除
aws cloudformation delete-stack \
  --stack-name my-stack \
  --profile your-profile

# 削除保護されたリソースがある場合
aws cloudformation update-stack \
  --stack-name my-stack \
  --use-previous-template \
  --parameters ParameterKey=DeletionPolicy,ParameterValue=Delete \
  --profile your-profile
```

### 3. 包括的な診断スクリプト

```bash
#!/bin/bash
# scripts/diagnose.sh

STACK_NAME="$1"
PROFILE="${2:-default}"

if [[ -z "$STACK_NAME" ]]; then
    echo "Usage: $0 STACK_NAME [PROFILE]"
    exit 1
fi

echo "=== CloudFormation Stack Diagnosis ==="
echo "Stack: $STACK_NAME"
echo "Profile: $PROFILE"
echo

# スタック基本情報
echo "--- Stack Status ---"
aws cloudformation describe-stacks \
  --stack-name "$STACK_NAME" \
  --profile "$PROFILE" \
  --query 'Stacks[0].[StackName, StackStatus, CreationTime, LastUpdatedTime]' \
  --output table

# 失敗したイベント
echo -e "\n--- Failed Events ---"
aws cloudformation describe-stack-events \
  --stack-name "$STACK_NAME" \
  --profile "$PROFILE" \
  --query 'StackEvents[?contains(ResourceStatus, `FAILED`)].[Timestamp, LogicalResourceId, ResourceStatus, ResourceStatusReason]' \
  --output table

# リソース状態
echo -e "\n--- Resource Status ---"
aws cloudformation describe-stack-resources \
  --stack-name "$STACK_NAME" \
  --profile "$PROFILE" \
  --query 'StackResources[*].[LogicalResourceId, ResourceType, ResourceStatus]' \
  --output table

# ドリフト検出
echo -e "\n--- Drift Detection ---"
DRIFT_ID=$(aws cloudformation detect-stack-drift \
  --stack-name "$STACK_NAME" \
  --profile "$PROFILE" \
  --query 'StackDriftDetectionId' \
  --output text)

sleep 10  # ドリフト検出完了待機

aws cloudformation describe-stack-drift-detection-status \
  --stack-drift-detection-id "$DRIFT_ID" \
  --profile "$PROFILE" \
  --query '[StackDriftDetectionId, StackDriftStatus, DriftedStackResourceCount]' \
  --output table
```

## セキュリティ

### 1. IAMベストプラクティス

#### 最小権限の原則
```yaml
Resources:
  LambdaExecutionRole:
    Type: AWS::IAM::Role
    Properties:
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Principal:
              Service: lambda.amazonaws.com
            Action: sts:AssumeRole
      ManagedPolicyArns:
        - arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
      Policies:
        - PolicyName: SpecificS3Access
          PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Effect: Allow
                Action:
                  - s3:GetObject
                  - s3:PutObject
                Resource: 
                  - !Sub arn:aws:s3:::${DataBucket}/*
              - Effect: Allow
                Action:
                  - s3:ListBucket
                Resource: 
                  - !Sub arn:aws:s3:::${DataBucket}
```

### 2. 機密情報管理

#### Systems Manager Parameter Store
```bash
# 機密情報をParameter Storeに保存
aws ssm put-parameter \
  --name /myapp/${ENVIRONMENT}/database/password \
  --value "secure-password-here" \
  --type SecureString \
  --key-id alias/aws/ssm \
  --profile your-profile

# CloudFormationでの参照
```

```yaml
Parameters:
  DatabasePassword:
    Type: AWS::SSM::Parameter::Value<String>
    Default: /myapp/prod/database/password
    NoEcho: true

Resources:
  Database:
    Type: AWS::RDS::DBInstance
    Properties:
      MasterUserPassword: !Ref DatabasePassword
      # その他の設定
```

#### Secrets Manager活用
```yaml
Resources:
  DatabaseSecret:
    Type: AWS::SecretsManager::Secret
    Properties:
      Name: !Sub ${AWS::StackName}-db-credentials
      Description: Database credentials for application
      GenerateSecretString:
        SecretStringTemplate: '{"username": "admin"}'
        GenerateStringKey: 'password'
        PasswordLength: 32
        ExcludeCharacters: '"@/\'

  Database:
    Type: AWS::RDS::DBInstance
    Properties:
      MasterUsername: !Sub '{{resolve:secretsmanager:${DatabaseSecret}:SecretString:username}}'
      MasterUserPassword: !Sub '{{resolve:secretsmanager:${DatabaseSecret}:SecretString:password}}'
```

### 3. スタックポリシー

#### 本番環境保護ポリシー（policies/stack-policy.json）
```json
{
  "Statement": [
    {
      "Effect": "Deny",
      "Principal": "*",
      "Action": "Update:Delete",
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "ResourceTag/Environment": "prod"
        }
      }
    },
    {
      "Effect": "Deny",
      "Principal": "*",
      "Action": "Update:Replace",
      "Resource": "LogicalResourceId/ProductionDatabase"
    },
    {
      "Effect": "Deny",
      "Principal": "*",
      "Action": "Update:Delete",
      "Resource": "LogicalResourceId/ProductionS3Bucket"
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

### 4. ログ記録と監視

#### CloudTrail統合
```yaml
Resources:
  CloudFormationLogGroup:
    Type: AWS::Logs::LogGroup
    Properties:
      LogGroupName: !Sub /aws/cloudformation/${AWS::StackName}
      RetentionInDays: 30

  CloudFormationEventRule:
    Type: AWS::Events::Rule
    Properties:
      Description: Monitor CloudFormation stack events
      EventPattern:
        source:
          - aws.cloudformation
        detail:
          stack-id:
            - !Ref AWS::StackId
      State: ENABLED
      Targets:
        - Arn: !GetAtt CloudFormationLogGroup.Arn
          Id: CloudFormationLogTarget
```

### 5. 完全な検証とデプロイのワークフロー

```bash
#!/bin/bash
# scripts/secure-deploy.sh

set -euo pipefail

STACK_NAME="$1"
ENVIRONMENT="$2"
TEMPLATE="templates/main.yaml"
PARAMETERS="parameters/$ENVIRONMENT.json"

# セキュリティチェック
echo "Running security checks..."

# 1. テンプレート検証
cfn-lint "$TEMPLATE"

# 2. セキュリティ分析
cfn_nag_scan --input-path "$TEMPLATE"

# 3. パラメータファイルの機密情報チェック
if grep -qi "password\|secret\|key" "$PARAMETERS"; then
    echo "WARNING: Potential secrets found in parameters file"
    exit 1
fi

# 4. 本番環境の追加確認
if [[ "$ENVIRONMENT" == "prod" ]]; then
    echo "PRODUCTION DEPLOYMENT DETECTED"
    echo "Additional security measures:"
    
    # MFA確認
    aws sts get-session-token --duration-seconds 900 >/dev/null
    
    # 承認者確認
    read -p "Enter approver name: " APPROVER
    echo "Deployment approved by: $APPROVER" >> deploy.log
fi

# 5. デプロイ実行
./scripts/deploy.sh -w "$STACK_NAME" "$ENVIRONMENT"

# 6. デプロイ後検証
echo "Running post-deployment verification..."
aws cloudformation describe-stacks \
  --stack-name "$STACK_NAME" \
  --query 'Stacks[0].StackStatus' \
  --output text

echo "Secure deployment completed successfully!"
```

---

## 参考リンク

- [AWS CloudFormation User Guide](https://docs.aws.amazon.com/cloudformation/)
- [CloudFormation Template Reference](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/template-reference.html)
- [AWS CLI CloudFormation Command Reference](https://docs.aws.amazon.com/cli/latest/reference/cloudformation/)
- [cfn-lint](https://github.com/aws-cloudformation/cfn-lint)
- [cfn_nag](https://github.com/stelligent/cfn_nag)