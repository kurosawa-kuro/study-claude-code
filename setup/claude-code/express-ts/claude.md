# Claude Code ドキュメント - Express 5 プロジェクト編

## 📋 プロジェクト概要

このドキュメントは、**Express 5 + OpenAPI + JSON DB + Jest** スタックでの Claude Code 活用方法をまとめています。

### 技術スタック
- **Runtime**: Node.js (18.x以上)
- **Framework**: Express 5.x
- **API仕様**: OpenAPI 3.0
- **Database**: json-server / lowdb
- **Testing**: Jest + Supertest
- **Language**: JavaScript (ES6+)

---

## 🚀 プロジェクト初期設定

### Express 5 プロジェクトのセットアップ

```bash
# プロジェクト作成
mkdir my-express-api && cd my-express-api
claude init

# package.json 生成
claude code "Generate package.json for Express 5 API with OpenAPI, json-server, Jest, and Supertest" -o package.json

# 基本構造の生成
claude code "Create Express 5 project structure with OpenAPI documentation" --prompt "
- Use Express 5.x
- Include OpenAPI 3.0 setup
- Add json-server for mock database
- Configure Jest and Supertest
- Create folder structure: src/, tests/, docs/
"
```

### .claude.json 設定ファイル

```json
{
  "project": "express-5-api",
  "language": "javascript",
  "framework": "express",
  "version": "5.x",
  "context": {
    "includePaths": ["src", "tests", "docs"],
    "excludePatterns": ["node_modules", "coverage", "*.log"],
    "additionalContext": [
      "package.json",
      "openapi.yaml",
      "db.json",
      "jest.config.js"
    ]
  },
  "templates": {
    "route": "Create Express 5 route with OpenAPI documentation",
    "middleware": "Create Express 5 middleware with error handling",
    "test": "Write Jest + Supertest integration tests",
    "openapi": "Generate OpenAPI 3.0 specification"
  },
  "codeStyle": {
    "esVersion": "ES2022",
    "semicolons": true,
    "quotes": "single",
    "indentation": 2
  }
}
```

---

## 📁 プロジェクト構造生成

```bash
# 完全なプロジェクト構造を生成
claude code "Generate complete Express 5 project structure" --prompt "
Create the following structure:
├── src/
│   ├── app.js              # Express app configuration
│   ├── server.js           # Server entry point
│   ├── routes/
│   │   ├── index.js
│   │   ├── users.js
│   │   └── products.js
│   ├── middleware/
│   │   ├── errorHandler.js
│   │   ├── validation.js
│   │   └── auth.js
│   ├── controllers/
│   │   ├── userController.js
│   │   └── productController.js
│   ├── models/
│   │   ├── user.js
│   │   └── product.js
│   └── utils/
│       ├── database.js     # json-server setup
│       └── logger.js
├── tests/
│   ├── integration/
│   │   ├── users.test.js
│   │   └── products.test.js
│   └── unit/
│       └── middleware.test.js
├── docs/
│   └── openapi.yaml
├── db.json
├── jest.config.js
└── .env.example
"
```

---

## 🔧 Express 5 専用コマンド

### アプリケーション初期化

```bash
# Express 5 アプリケーションの基本設定
claude code "Create Express 5 app.js with OpenAPI middleware" -o src/app.js --prompt "
- Use Express 5 features (async/await route handlers)
- Add OpenAPI validation middleware
- Configure CORS, helmet, compression
- Add request logging with morgan
- Setup error handling middleware
"

# サーバーエントリーポイント
claude code "Create Express 5 server.js with graceful shutdown" -o src/server.js
```

### ルート生成

```bash
# RESTful API ルート生成
claude code "Create Express 5 REST routes for users" -o src/routes/users.js --prompt "
- GET /users (list all)
- GET /users/:id (get one)
- POST /users (create)
- PUT /users/:id (update)
- DELETE /users/:id (delete)
- Use Express 5 async route handlers
- Include OpenAPI annotations
"

# コントローラー生成
claude code "Create user controller with json-server integration" -o src/controllers/userController.js --prompt "
- Connect to json-server/lowdb
- Implement CRUD operations
- Add input validation
- Handle errors properly
"
```

### OpenAPI ドキュメント生成

```bash
# OpenAPI 仕様書の生成
claude code "Generate OpenAPI 3.0 specification for user API" -o docs/openapi.yaml --prompt "
- Include all CRUD endpoints
- Add request/response schemas
- Include authentication specs
- Add example values
- Include error responses
"

# OpenAPIからコード生成
claude --file docs/openapi.yaml "Generate Express routes from this OpenAPI spec"

# Swagger UI 設定
claude code "Setup Swagger UI for Express 5" -o src/middleware/swagger.js
```

### データベース設定

```bash
# json-server セットアップ
claude code "Create json-server database configuration" -o src/utils/database.js --prompt "
- Use lowdb for data persistence
- Create db.json structure
- Add seed data
- Implement database utilities
"

# 初期データ生成
claude code "Generate sample data for json database" -o db.json --prompt "
Create sample data:
- 10 users with realistic data
- 20 products with categories
- Proper relationships
"
```

### ミドルウェア生成

```bash
# エラーハンドリング
claude code "Create Express 5 error handling middleware" -o src/middleware/errorHandler.js --prompt "
- Handle different error types
- Log errors appropriately
- Send proper HTTP responses
- Support async errors
"

# バリデーション
claude code "Create validation middleware using Joi" -o src/middleware/validation.js

# 認証
claude code "Create JWT authentication middleware" -o src/middleware/auth.js
```

---

## 🧪 テスト関連コマンド

### Jest 設定

```bash
# Jest設定ファイル生成
claude code "Create Jest configuration for Express API testing" -o jest.config.js --prompt "
- Configure for Node.js environment
- Setup coverage reporting
- Add test match patterns
- Configure test timeouts
"

# テストユーティリティ
claude code "Create test utilities and helpers" -o tests/utils/testHelpers.js
```

### テスト生成

```bash
# 統合テスト生成
claude code "Write Supertest integration tests for user API" -o tests/integration/users.test.js --prompt "
- Test all CRUD operations
- Test error cases
- Test validation
- Use Supertest for HTTP testing
- Mock json-server if needed
"

# ユニットテスト生成
claude code "Write unit tests for error handler middleware" -o tests/unit/errorHandler.test.js

# 既存コードからテスト生成
claude --file src/controllers/userController.js "Generate comprehensive Jest tests for this controller"
```

### テスト実行とデバッグ

```bash
# テスト失敗の分析
npm test 2>&1 | claude fix

# カバレッジ向上の提案
claude --file coverage/lcov-report/index.html "Suggest tests to improve coverage"

# テストのリファクタリング
claude review tests/ --prompt "Improve test quality and reduce duplication"
```

---

## 📝 開発ワークフロー

### 新機能開発

```bash
# 1. OpenAPI仕様を更新
claude --file docs/openapi.yaml "Add endpoint for user search with query parameters"

# 2. ルートを生成
claude code "Implement user search endpoint based on OpenAPI spec" -o src/routes/users.js

# 3. コントローラーを実装
claude code "Implement search logic in user controller" -o src/controllers/userController.js

# 4. テストを作成
claude code "Write tests for user search functionality" -o tests/integration/userSearch.test.js

# 5. ドキュメントを更新
claude docs --format markdown -o API.md
```

### デバッグとエラー修正

```bash
# エラーログ分析
claude --file error.log "Analyze this Express error and suggest fixes"

# パフォーマンス問題
claude review src/routes/ --prompt "Identify performance bottlenecks and suggest optimizations"

# メモリリーク検出
claude "How to detect and fix memory leaks in this Express 5 app"
```

### コードレビューと品質向上

```bash
# セキュリティレビュー
claude review src/ --prompt "Check for security vulnerabilities in Express routes"

# ベストプラクティス確認
claude review src/app.js --prompt "Verify Express 5 best practices"

# リファクタリング提案
claude --directory src/controllers "Suggest refactoring to improve maintainability"
```

---

## 🚀 高度な使用例

### マイグレーション支援

```bash
# Express 4 から 5 への移行
claude --file app.js "Migrate this Express 4 app to Express 5" --prompt "
- Update deprecated methods
- Convert to async/await
- Update middleware usage
- Maintain backward compatibility
"
```

### API仕様からの自動生成

```bash
# OpenAPI から完全な実装を生成
claude --file docs/openapi.yaml "Generate complete Express 5 implementation" --prompt "
Generate:
1. All route files
2. Controller implementations
3. Validation middleware
4. Test files
5. Mock data
"
```

### CI/CD 統合

```bash
# GitHub Actions ワークフロー生成
claude code "Create GitHub Actions workflow for Express API" -o .github/workflows/ci.yml --prompt "
- Run tests on push
- Check code quality
- Generate coverage reports
- Deploy to staging
"
```

---

## 🛠️ トラブルシューティング

### よくある Express 5 の問題

```bash
# Promise rejection の処理
claude "How to handle unhandled promise rejections in Express 5"

# ミドルウェアの順序問題
claude review src/app.js --prompt "Check middleware order and potential conflicts"

# json-server の同期問題
claude --file src/utils/database.js "Fix race conditions in json-server operations"
```

### パフォーマンス最適化

```bash
# ルートの最適化
claude review src/routes/ --prompt "Optimize Express routes for better performance"

# データベースクエリの改善
claude --file src/controllers/userController.js "Optimize database queries"

# キャッシング戦略
claude "Implement caching strategy for Express 5 API with json-server"
```

---

## 📊 プロジェクト別エイリアス

```bash
# ~/.bashrc or ~/.zshrc に追加

# Express 5 プロジェクト用
alias cce5='claude --context package.json,src/app.js'
alias cce5route='claude code "Create Express 5 route with async/await"'
alias cce5test='claude code "Write Supertest integration test"'
alias cce5api='claude --file docs/openapi.yaml'

# テスト関連
alias cctest='npm test 2>&1 | claude fix'
alias cctestgen='claude code "Generate Jest tests for"'
alias cccoverage='claude --file coverage/lcov.info "Improve test coverage"'

# デバッグ関連
alias cce5debug='claude "Debug this Express 5 error:"'
alias cce5perf='claude review --prompt "Optimize performance"'
alias cce5security='claude review --prompt "Security audit"'
```

---

## 📚 リソースとベストプラクティス

### Express 5 特有の考慮事項

```bash
# Express 5 の新機能を活用
claude "Show Express 5 new features and how to use them in my project"

# エラーハンドリングのベストプラクティス
claude "Express 5 error handling best practices with examples"

# 非同期ルートハンドラーの適切な使用
claude "Proper async/await usage in Express 5 routes"
```

### プロジェクトテンプレート

```bash
# 完全なボイラープレート生成
claude code "Generate complete Express 5 boilerplate" --prompt "
Include:
- Express 5 with all best practices
- OpenAPI documentation
- json-server setup
- Jest + Supertest configuration
- Docker support
- Environment configuration
- Logging setup
- Error handling
- Security middleware
"
```

このドキュメントを参考に、Express 5 プロジェクトで Claude Code を効果的に活用してください。