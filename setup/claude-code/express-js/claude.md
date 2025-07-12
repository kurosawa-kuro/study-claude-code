# Claude Code ドキュメント - Express 5

## 📋 プロジェクト概要

Express 5 のフルスタック開発環境における Claude Code 完全活用ガイド。OpenAPI駆動開発、型安全なバリデーション、包括的なセキュリティ対策、効率的なタスク管理を実現。

### 🛠️ 技術スタック

#### コアフレームワーク
- **Runtime**: Node.js 18.x+
- **Framework**: Express 5.x
- **Database**: lowdb (JSON ファイルベース)
- **API仕様**: OpenAPI 3.0 + openapi-backend
- **バリデーション**: Zod
- **エラーハンドリング**: express-async-errors
- **タスクランナー**: Make

#### ミドルウェア・ユーティリティ
- **環境変数**: dotenv
- **CORS**: cors
- **ロギング**: morgan
- **開発**: nodemon
- **セキュリティ**: helmet
- **Cookie処理**: cookie-parser
- **エラー生成**: http-errors
- **ファイル操作**: fs-extra

#### 認証・セッション
- **JWT**: jsonwebtoken
- **暗号化**: bcrypt
- **セッション**: express-session
- **キャッシュ**: redis (オプション)

#### テスト・ドキュメント
- **テスト**: Jest + Supertest
- **APIドキュメント**: Swagger UI Express

---

## 🚀 プロジェクト初期化

### 完全なプロジェクトセットアップ

```bash
# プロジェクト作成
mkdir express5-complete-api && cd express5-complete-api
claude init

# package.json 生成（全依存関係含む）
claude code "Generate complete Express 5 package.json" -o package.json --prompt "
Create package.json with:
- Express 5.x with express-async-errors
- lowdb for JSON database
- openapi-backend, swagger-ui-express
- Zod for validation
- All security middleware (helmet, cors, etc)
- Morgan for logging, dotenv for config
- JWT and session management
- Testing tools (Jest, Supertest)
- Development tools (nodemon, concurrently)
- Scripts: dev, test, build, seed, migrate
"
```

### プロジェクト構造生成

```bash
# 完全なディレクトリ構造を作成
claude code "Generate complete Express 5 project structure" --prompt "
Create this exact structure:
project-root/
├── src/
│   ├── controllers/        # ビジネスロジック
│   ├── middlewares/        # カスタムミドルウェア
│   ├── models/            # データモデル定義
│   ├── repositories/      # データアクセス層
│   ├── routes/            # Express ルーター
│   ├── services/          # ビジネスロジックサービス
│   ├── utils/             # ユーティリティ関数
│   ├── schemas/           # Zod バリデーションスキーマ
│   ├── config/            # 設定ファイル
│   └── server.js          # アプリケーションエントリーポイント
├── openapi/
│   └── api.yaml           # OpenAPI 3.x 仕様書
├── db/
│   ├── db.json           # lowdb データファイル
│   ├── migrations/       # データベースマイグレーション
│   └── seed.js           # 初期データ投入スクリプト
├── tests/
│   ├── unit/
│   ├── integration/
│   ├── fixtures/
│   └── utils/
├── scripts/              # ユーティリティスクリプト
├── logs/                 # ログファイル
├── docs/                 # ドキュメント
├── .env.example
├── .env.development
├── .env.test
├── .gitignore
├── .eslintrc.js
├── .prettierrc
├── jest.config.js
├── nodemon.json
├── Makefile              # プロジェクトタスク定義
├── Dockerfile
├── docker-compose.yml
└── README.md
"
```

### .claude.json 設定

```json
{
  "project": "express5-complete-api",
  "language": "javascript",
  "framework": "express",
  "version": "5.x",
  "database": "lowdb",
  "context": {
    "includePaths": ["src", "tests", "openapi", "db"],
    "excludePatterns": ["node_modules", "coverage", "logs", "*.log", ".env"],
    "additionalContext": [
      "package.json",
      "openapi/api.yaml",
      "db/db.json",
      ".env.example",
      "jest.config.js",
      "Makefile"
    ]
  },
  "dependencies": {
    "validation": "zod",
    "api-spec": "openapi-backend",
    "error-handling": "express-async-errors",
    "documentation": "swagger-ui-express",
    "database": "lowdb",
    "logging": "morgan"
  },
  "templates": {
    "controller": "Create controller with Zod validation and error handling",
    "route": "Create Express 5 route with OpenAPI integration",
    "model": "Create lowdb model with validation",
    "schema": "Create Zod schema with OpenAPI compatibility",
    "middleware": "Create middleware with async error handling",
    "service": "Create service layer with business logic",
    "test": "Write comprehensive tests with Supertest",
    "migration": "Create database migration script"
  },
  "codeStyle": {
    "esVersion": "ES2022",
    "semicolons": true,
    "quotes": "single",
    "indentation": 2,
    "lineLength": 100
  }
}
```

---

## 📝 Makefile - プロジェクトタスク管理

### 包括的な Makefile

```bash
# Makefile 生成
claude code "Create comprehensive Makefile" -o Makefile --prompt "
Create production-ready Makefile with:

# === Configuration ===
- Color output support
- OS detection
- Environment variables
- Path configurations

# === Primary Targets ===
help: Show all available commands
install: Install all dependencies
setup: Complete project setup
dev: Start development server
test: Run test suite
build: Build for production
deploy: Deploy application

# === Development ===
dev-debug: Debug mode
watch: Watch files
lint: Code linting
format: Code formatting
type-check: Type checking

# === Database ===
db-seed: Seed database
db-migrate: Run migrations
db-backup: Backup database
db-restore: Restore database
db-reset: Reset database
db-view: Database GUI

# === Testing ===
test-unit: Unit tests
test-integration: Integration tests
test-e2e: End-to-end tests
coverage: Coverage report
test-watch: Watch mode

# === Documentation ===
docs-api: Generate API docs
docs-code: Generate code docs
swagger: Swagger UI

# === Docker ===
docker-build: Build image
docker-run: Run container
docker-compose: Run with compose

# === Utilities ===
clean: Clean build files
logs: View logs
health: Health check
update: Update dependencies

Include proper error handling and dependencies
"
```

---

## 🔧 コア実装

### サーバーとアプリケーション設定

```bash
# Express 5 サーバー設定
claude code "Create Express 5 server with all features" -o src/server.js --prompt "
Implement Express 5 server:
- Load environment variables with dotenv
- Setup express-async-errors
- Configure all middleware in correct order:
  - Security (helmet, cors)
  - Logging (morgan)
  - Parsing (json, urlencoded, cookies)
  - Session management
  - Static files
  - API routes
  - OpenAPI/Swagger
  - Error handling
- Graceful shutdown
- Cluster support option
"

# 設定管理
claude code "Create configuration module" -o src/config/index.js --prompt "
Configuration module with:
- Environment-based config
- Validation of required variables
- Type casting
- Default values
- Export typed config object
"
```

### データベース層 (lowdb)

```bash
# データベース初期化
claude code "Create lowdb database setup" -o src/utils/database.js --prompt "
lowdb configuration:
- Singleton pattern
- Async adapter
- Default schema
- Migration support
- Backup functionality
- Connection pooling simulation
- Error handling
"

# ベースモデル
claude code "Create base model class" -o src/models/BaseModel.js --prompt "
Base model with:
- CRUD operations
- Query builder
- Validation hooks
- Timestamps
- Soft delete
- Relationships
- Pagination
- Search functionality
"

# リポジトリパターン
claude code "Create base repository" -o src/repositories/BaseRepository.js --prompt "
Repository pattern:
- Data access abstraction
- Complex queries
- Transactions simulation
- Caching layer
- Performance optimization
"
```

### API層実装

```bash
# OpenAPI 統合
claude code "Setup OpenAPI backend" -o src/utils/openapi.js --prompt "
OpenAPI setup:
- Load specification
- Request validation
- Response validation
- Security handlers
- Error formatting
- Route registration
"

# Zod スキーマ
claude code "Create user schemas" -o src/schemas/user.schema.js --prompt "
Zod schemas for:
- User creation
- User update
- Query parameters
- Login/Register
- Password reset
- Profile update
With OpenAPI compatibility
"

# バリデーションミドルウェア
claude code "Create validation middleware" -o src/middlewares/validation.js --prompt "
Validation middleware:
- Body validation
- Query validation
- Params validation
- File validation
- Custom validators
- Error formatting
"
```

### ビジネスロジック層

```bash
# サービス層
claude code "Create user service" -o src/services/user.service.js --prompt "
User service with:
- Business logic separation
- Transaction coordination
- Event emission
- Cache management
- External API calls
- Error handling
"

# コントローラー
claude code "Create user controller" -o src/controllers/user.controller.js --prompt "
User controller:
- RESTful endpoints
- Authentication
- Authorization
- Input validation
- Response formatting
- Error handling
- Pagination
- Search/Filter
"
```

### セキュリティとミドルウェア

```bash
# 認証ミドルウェア
claude code "Create auth middleware" -o src/middlewares/auth.js --prompt "
Authentication:
- JWT validation
- Token refresh
- Session support
- Role-based access
- API key support
- OAuth integration
"

# エラーハンドラー
claude code "Create error handler" -o src/middlewares/errorHandler.js --prompt "
Global error handler:
- Error classification
- Status code mapping
- Logging integration
- Stack trace handling
- Client-safe responses
- Development vs Production
"

# セキュリティ設定
claude code "Create security config" -o src/middlewares/security.js --prompt "
Security middleware:
- Helmet configuration
- CORS setup
- Rate limiting
- Input sanitization
- CSRF protection
- Content Security Policy
"
```

---

## 🧪 テスト戦略

### テスト設定

```bash
# Jest 設定
claude code "Create Jest configuration" -o jest.config.js --prompt "
Jest config with:
- Test environments
- Coverage settings
- Module paths
- Setup files
- Custom matchers
- Test patterns
"

# テストユーティリティ
claude code "Create test utilities" -o tests/utils/helpers.js --prompt "
Test helpers:
- Database setup/teardown
- Authentication helpers
- Request builders
- Mock factories
- Custom assertions
- Fixture loaders
"
```

### テスト実装

```bash
# 統合テスト
claude code "Create API integration tests" -o tests/integration/users.test.js --prompt "
Comprehensive tests:
- CRUD operations
- Authentication flows
- Validation errors
- Pagination
- Search/Filter
- Rate limiting
- Error scenarios
- Performance tests
"

# ユニットテスト
claude code "Create service unit tests" -o tests/unit/userService.test.js --prompt "
Unit tests for:
- Business logic
- Data transformations
- Validation rules
- Error handling
- Edge cases
"
```

---

## 🚀 開発ワークフロー

### 開発環境セットアップ

```bash
# 環境別設定ファイル
claude code "Create environment configs" --prompt "
Create:
- .env.example (template)
- .env.development (dev settings)
- .env.test (test settings)
- .env.production (prod template)
With all required variables documented
"

# 開発ツール設定
claude code "Create development configs" --prompt "
Create:
- nodemon.json (hot reload)
- .eslintrc.js (linting)
- .prettierrc (formatting)
- .editorconfig (editor)
- .gitignore (comprehensive)
"
```

### CI/CD 設定

```bash
# GitHub Actions
claude code "Create CI/CD pipeline" -o .github/workflows/main.yml --prompt "
CI/CD pipeline:
- Multiple Node versions
- Lint and format check
- Unit and integration tests
- Coverage reporting
- Security scanning
- Docker build
- Deployment stages
- Release automation
"

# Docker設定
claude code "Create Docker setup" --prompt "
Create:
- Dockerfile (multi-stage)
- docker-compose.yml
- .dockerignore
With optimization and security
"
```

---

## 📊 プロジェクト別エイリアス

```bash
# ~/.bashrc or ~/.zshrc に追加

# === Make ショートカット ===
alias m='make'
alias mh='make help'
alias md='make dev'
alias mt='make test'
alias mb='make build'

# === Claude Code 統合 ===
# プロジェクト全体
alias cc='claude --context package.json,openapi/api.yaml,src/server.js,.env.example'
alias ccfull='claude --directory . --recursive --exclude node_modules,coverage,logs'

# コード生成
alias cccontroller='claude code "Create controller for"'
alias ccservice='claude code "Create service for"'
alias ccmodel='claude code "Create lowdb model for"'
alias ccroute='claude code "Create Express 5 route for"'
alias ccschema='claude code "Create Zod schema for"'
alias ccmiddleware='claude code "Create middleware for"'
alias cctest='claude code "Create tests for"'

# データベース
alias ccdb='claude --context db/db.json,src/utils/database.js'
alias ccseed='claude code "Create seed data for"'
alias ccmigration='claude code "Create migration for"'

# API仕様
alias ccapi='claude --file openapi/api.yaml'
alias ccswagger='claude code "Update Swagger docs for"'

# デバッグ・修正
alias ccfix='claude fix'
alias ccdebug='claude "Debug this error:"'
alias ccreview='claude review'
alias ccoptimize='claude review --prompt "Optimize for performance"'
alias ccsecurity='claude review --prompt "Security audit"'

# テスト
alias cctest-unit='claude code "Write unit tests for"'
alias cctest-int='claude code "Write integration tests for"'
alias cctest-fix='npm test 2>&1 | claude fix'

# === 複合コマンド ===
# 新機能開発フロー
alias ccfeature='f() { ccschema "$1" && ccmodel "$1" && ccservice "$1" && cccontroller "$1" && ccroute "$1" && cctest "$1"; }; f'

# プロジェクトセットアップ
alias ccsetup='make clean install setup db-seed'

# デプロイ前チェック
alias ccpredeploy='make lint test security-check build'
```

---

## 🎯 ベストプラクティス

### コード品質維持

```bash
# コードレビュー依頼
claude review src/ --prompt "
Review for:
- Express 5 best practices
- Security vulnerabilities
- Performance issues
- Error handling
- Code organization
- Documentation completeness
"

# リファクタリング提案
claude review src/controllers/ --prompt "
Suggest refactoring for:
- Code duplication
- Complex functions
- Better abstractions
- Design patterns
- Testability improvements
"
```

### パフォーマンス最適化

```bash
# パフォーマンス分析
claude analyze --prompt "
Analyze for performance:
- Database query optimization
- Caching opportunities
- Memory usage
- Response time optimization
- Concurrent request handling
"
```

### セキュリティ強化

```bash
# セキュリティ監査
claude review --prompt "
Security audit:
- Input validation completeness
- Authentication flows
- Authorization checks
- Injection vulnerabilities
- Sensitive data exposure
- Rate limiting adequacy
"
```

---

## 📚 ドキュメント生成

### プロジェクトドキュメント

```bash
# README生成
claude docs "Generate comprehensive README.md" --prompt "
Include:
- Project overview
- Tech stack details
- Setup instructions
- API documentation
- Development guide
- Testing guide
- Deployment guide
- Contributing guidelines
"

# API仕様書
claude docs "Generate API documentation" --prompt "
Create detailed API docs:
- Endpoint descriptions
- Request/Response examples
- Authentication guide
- Error codes
- Rate limits
- Webhooks
"
```
