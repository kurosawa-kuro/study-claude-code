# Claude Code ドキュメント – Express.js EJS モノリシック版

---

## 📋 プロジェクト概要

Express.js 5 + EJS を使った **モノリシック フルスタック PoC** を短期間で立ち上げるための Claude Code 活用ガイドです。画面描画とAPI機能を一つのサーバーで提供し、セッション認証・型安全バリデーション・セキュリティ対策を最小コストで導入します。将来のマイクロサービス分割も見据えた柔軟な設計を目指します。

---

## ⚙️ 設計 & PoC 方針

### 設計思想

* **OpenAPI → テストコード → 実装（モデル → サービス → コントローラー）**
* **openapi-backend により OpenAPI を “Single Source of Truth” として厳格運用（API 契約 = 唯一の真実）**
* **MVC + API 二層構造でモノリシック アーキテクチャを実現**
* **EJS による画面描画 + REST API の併設で、単一サーバーでフルスタック対応**
* **セッション認証による画面アクセス制御と、API認証の両立**
* **後日マイクロサービス分割を見据えた疎結合設計**

#### 開発フロー

1. **Step‑1** EJS テンプレートと画面ルーターで基本的なUI構築
2. **Step‑2** セッション認証フローの実装（ログイン・ログアウト）
3. **Step‑3** API エンドポイントの実装（/api プレフィックス）

   1. データモデル (lowdb + Zod validation)
   2. サービス層 (ビジネスロジック)
   3. API コントローラ (JSON レスポンス)
   4. View コントローラ (EJS レンダリング)
4. **Step‑4** 画面からAPIへのAjax連携とフィードバック表示
5. **Step‑5** テストコード（Jest + Supertest）でAPI部分を担保

### PoC 制約

* **Destroy／Update** エンドポイントは作成しない
* ファイル・画像アップロード機能は不要
* ユーザーログインは明確な指示が無い限り実装しない

---

## 🛠️ 技術スタック

### コアフレームワーク

| 項目             | 採用ライブラリ                                            |
| -------------- | -------------------------------------------------- |
| Runtime        | **Node.js 18 LTS**                                 |
| Framework      | **Express.js 5.x** (+ express‑async‑errors + EJS)  |
| View Engine    | **EJS** (+ express‑ejs‑layouts)                    |
| Database       | **lowdb** (JSON ファイル)                              |
| Validation     | **Zod** (アプリ層) ／ **Ajv + ajv‑formats** (OpenAPI 層) |
| Error Handling | express‑async‑errors                               |
| Task Runner    | Make                                               |

### ミドルウェア & ユーティリティ

* dotenv · cors · helmet · morgan · cookie‑parser · express‑session · http‑errors · fs‑extra · nodemon · express‑ejs‑layouts

### 認証・セッション

* **express‑session** (メイン認証) · bcrypt (パスワードハッシュ) · jsonwebtoken (API認証・オプション)

### テスト & ドキュメント

* Jest · Supertest · (Swagger UI Express・オプション)

---

## 🚀 プロジェクト初期化

### 1. プロジェクトセットアップ

```bash
# プロジェクト作成
mkdir express-ejs-monolith && cd express-ejs-monolith
claude init

# package.json 生成
claude code "Generate complete Express.js EJS package.json" -o package.json --prompt "
Create package.json with:
- Express.js 5.x with express-async-errors
- EJS and express-ejs-layouts for views
- express-session for authentication
- lowdb for JSON database
- Zod for validation  
- All security middleware (helmet, cors, etc.)
- Morgan for logging, dotenv for config
- bcrypt for password hashing
- Testing tools (Jest, Supertest)
- Development tools (nodemon, concurrently)
- Scripts: dev, test, build, seed, migrate
"
```

### 2. ディレクトリ構造

```
project-root/
├── src/
│   ├── controllers/        # JSON API コントローラ
│   ├── viewControllers/    # 画面レンダリング コントローラ
│   ├── middlewares/        # カスタムミドルウェア
│   ├── models/             # ドメインモデル
│   ├── repositories/       # データアクセス
│   ├── routes/
│   │   ├── api/            # API ルーター (/api)
│   │   └── web/            # 画面ルーター (/)
│   ├── services/           # ビジネスロジック
│   ├── utils/              # 共通ユーティリティ
│   ├── schemas/            # Zod スキーマ
│   ├── config/             # 設定モジュール
│   ├── views/              # EJS テンプレート
│   │   ├── layouts/        # 共通レイアウト
│   │   ├── pages/          # ページテンプレート
│   │   └── partials/       # パーシャル
│   └── server.js           # エントリーポイント
├── public/                 # 静的ファイル (CSS, JS, images)
├── db/
│   ├── db.json             # lowdb ファイル
│   ├── migrations/         # DB マイグレーション
│   └── seed.js             # 初期データ
├── tests/
│   ├── unit/
│   ├── integration/
│   ├── fixtures/
│   └── utils/
├── scripts/                # 補助スクリプト
├── logs/
├── docs/
├── .env.*
├── Makefile
├── Dockerfile / docker-compose.yml
└── README.md
```

### 3. .claude.json 設定

```json
{
  "project": "express-ejs-monolith",
  "language": "javascript",
  "framework": "express",
  "architecture": "monolithic",
  "version": "5.x",
  "viewEngine": "ejs",
  "database": "lowdb",
  "context": {
    "includePaths": ["src", "tests", "public", "db"],
    "excludePatterns": ["node_modules", "coverage", "logs", "*.log", ".env"],
    "additionalContext": [
      "package.json",
      "db/db.json",
      ".env.example",
      "jest.config.js",
      "Makefile"
    ]
  },
  "dependencies": {
    "validation": "zod",
    "viewEngine": "ejs",
    "authentication": "express-session",
    "error-handling": "express-async-errors",
    "database": "lowdb",
    "logging": "morgan"
  },
  "templates": {
    "apiController": "Create API controller with JSON responses and Zod validation",
    "viewController": "Create view controller with EJS rendering and session handling",
    "route": "Create Express.js route with proper middleware",
    "view": "Create EJS template with layout support",
    "model": "Create lowdb model with validation",
    "schema": "Create Zod schema for validation",
    "middleware": "Create middleware with async error handling",
    "service": "Create service layer with business logic",
    "test": "Write comprehensive tests with Supertest"
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

## 📝 プロジェクトタスク管理

### Makefile セットアップ

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
dev: Start development server with EJS hot reload
test: Run test suite
build: Build for production
deploy: Deploy application

# === Development ===
dev-debug: Debug mode
watch: Watch files (including EJS templates)
lint: Code linting
format: Code formatting
type-check: Type checking

# === Database ===
db-seed: Seed database
db-migrate: Run migrations
db-backup: Backup database
db-restore: Restore database
db-reset: Reset database

# === Testing ===
test-unit: Unit tests
test-integration: Integration tests
test-e2e: End-to-end tests
coverage: Coverage report
test-watch: Watch mode

# === Assets ===
assets-build: Build CSS/JS assets
assets-watch: Watch assets for changes

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

## 🔧 実装ガイド

### 1. サーバー設定

```bash
# Express.js EJS サーバー設定
claude code "Create Express.js EJS server with all features" -o src/server.js --prompt "
Implement Express.js 5 server with EJS:
- Load environment variables with dotenv
- Setup express-async-errors
- Configure EJS view engine with express-ejs-layouts
- Setup static file serving from public/
- Configure all middleware in correct order:
  - Security (helmet, cors)
  - Logging (morgan)
  - Parsing (json, urlencoded, cookies)
  - Session management (express-session)
  - Static files
  - Web routes (/) for EJS pages
  - API routes (/api) for JSON responses
  - Error handling
- Graceful shutdown
- Session-based authentication middleware
"

# 設定管理
claude code "Create configuration module" -o src/config/index.js --prompt "
Configuration module with:
- Environment-based config
- Validation of required variables
- Session configuration
- Database paths
- View engine settings
- Static file paths
- Type casting and default values
- Export typed config object
"
```

### 2. EJS ビュー設定

```bash
# レイアウトとパーシャル
claude code "Create EJS layout system" --prompt "
Create EJS templates:
- views/layouts/main.ejs (main layout)
- views/partials/header.ejs (navigation)
- views/partials/footer.ejs
- views/pages/index.ejs (home page)
- views/pages/login.ejs (login form)
- views/pages/dashboard.ejs (user dashboard)
- views/pages/error.ejs (error page)
With proper meta tags, CSS includes, and responsive design
"

# CSS/JS 静的ファイル
claude code "Create static assets structure" --prompt "
Create public/ structure:
- public/css/main.css (main stylesheet)
- public/js/main.js (main JavaScript)
- public/js/auth.js (authentication handling)
- public/images/ (placeholder images)
Include basic responsive CSS and JavaScript for form handling
"
```

### 3. 認証システム

```bash
# セッション認証
claude code "Create session authentication system" -o src/middlewares/auth.js --prompt "
Session authentication middleware:
- requireAuth: Redirect to login if not authenticated
- requireGuest: Redirect to dashboard if authenticated
- setUser: Add user info to res.locals for templates
- Session management helpers
- Password hashing utilities with bcrypt
- Login/logout handlers
"

# 認証ルーター
claude code "Create authentication routes" -o src/routes/web/auth.js --prompt "
Authentication web routes:
- GET /login (show login form)
- POST /login (process login)
- GET /register (show registration form)
- POST /register (process registration)
- GET /logout (logout and redirect)
- Password reset flow (optional)
With proper validation and error handling
"
```

### 4. データ層実装

```bash
# データベース初期化
claude code "Create lowdb database setup" -o src/utils/database.js --prompt "
lowdb configuration:
- Singleton pattern
- Async adapter
- Default schema with users table
- Migration support
- User model with bcrypt integration
- Connection helpers
- Error handling
"

# ユーザーモデル
claude code "Create user model" -o src/models/User.js --prompt "
User model with:
- CRUD operations
- Password hashing/verification
- User validation
- Session serialization
- Role management (optional)
- Timestamps
- Query helpers
"
```

### 5. API とビューコントローラー分離

```bash
# API コントローラー
claude code "Create API controllers" -o src/controllers/user.controller.js --prompt "
JSON API controller:
- RESTful endpoints returning JSON
- Input validation with Zod
- Error handling with proper status codes
- Authentication middleware integration
- Pagination and filtering
- Consistent response format
"

# ビューコントローラー
claude code "Create view controllers" -o src/viewControllers/user.controller.js --prompt "
EJS view controller:
- Render EJS templates with data
- Handle form submissions
- Session flash messages
- CSRF protection
- Redirect after POST pattern
- Error page rendering
- User dashboard functionality
"

# ルーター分離
claude code "Create route separation" --prompt "
Create separate routers:
- src/routes/api/index.js (API routes with /api prefix)
- src/routes/web/index.js (Web routes for EJS pages)
- Proper middleware application
- Route protection
- Error boundary separation
"
```

### 6. フロントエンド連携

```bash
# Ajax API 連携
claude code "Create frontend API integration" -o public/js/api.js --prompt "
Frontend JavaScript for API integration:
- CSRF token handling
- Fetch API wrapper with authentication
- Form submission helpers
- Error message display
- Loading states
- Success/error notifications
- Client-side validation
"

# フォーム処理
claude code "Create form handling utilities" -o public/js/forms.js --prompt "
Form handling JavaScript:
- Progressive enhancement
- Client-side validation
- AJAX form submission
- File upload support
- Real-time validation feedback
- Error message display
- Success redirects
"
```

---

## 🧪 テスト実装

### 1. テスト環境設定

```bash
# Jest 設定
claude code "Create Jest configuration" -o jest.config.js --prompt "
Jest config for Express EJS app:
- Test environments (unit, integration)
- Coverage settings
- Module paths
- Setup files for database
- Mock configurations
- EJS template testing support
- Session testing utilities
"

# テストユーティリティ
claude code "Create test utilities" -o tests/utils/helpers.js --prompt "
Test helpers for EJS app:
- Database setup/teardown
- Session creation helpers
- Request builders with authentication
- EJS rendering test utilities
- Mock factories for users
- Custom assertions
- Fixture loaders
"
```

### 2. テスト実装

```bash
# API 統合テスト
claude code "Create API integration tests" -o tests/integration/api.test.js --prompt "
API integration tests:
- Authentication endpoints
- CRUD operations
- Input validation
- Error handling
- Session management
- Rate limiting
- Security tests
"

# ビュー統合テスト
claude code "Create view integration tests" -o tests/integration/views.test.js --prompt "
View integration tests:
- Page rendering
- Form submissions
- Authentication flows
- Session handling
- Error page rendering
- Redirect behavior
- Template data passing
"

# ユニットテスト
claude code "Create unit tests" --prompt "
Unit tests for:
- User model operations
- Authentication middleware
- Validation schemas
- Service layer logic
- Utility functions
- Error handling
"
```

---

## 🚀 開発環境とCI/CD

### 1. 開発環境設定

```bash
# 環境別設定ファイル
claude code "Create environment configs" --prompt "
Create:
- .env.example (template with all variables)
- .env.development (dev settings)
- .env.test (test settings)
- .env.production (prod template)
Include session secrets, database paths, view settings
"

# 開発ツール設定
claude code "Create development configs" --prompt "
Create:
- nodemon.json (hot reload for EJS + JS)
- .eslintrc.js (linting)
- .prettierrc (formatting)
- .editorconfig (editor)
- .gitignore (comprehensive)
"
```

### 2. セキュリティ設定

```bash
# CSRF保護
claude code "Create CSRF protection" -o src/middlewares/csrf.js --prompt "
CSRF protection middleware:
- Token generation and validation
- EJS template integration
- Form helper functions
- AJAX request handling
- Error handling
"

# セキュリティ設定
claude code "Create security config" -o src/middlewares/security.js --prompt "
Security middleware:
- Helmet configuration for EJS
- CORS setup for API
- Rate limiting
- Input sanitization
- Session security
- Content Security Policy
"
```

---

## 📊 Claude Code エイリアス

### 開発効率化エイリアス

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
alias cc='claude --context package.json,src/server.js,.env.example'
alias ccfull='claude --directory . --recursive --exclude node_modules,coverage,logs'

# EJS 開発
alias ccview='claude code "Create EJS view for"'
alias cclayout='claude code "Create EJS layout for"'
alias ccpartial='claude code "Create EJS partial for"'

# コントローラー生成
alias ccapi='claude code "Create API controller for"'
alias ccweb='claude code "Create view controller for"'
alias ccroute='claude code "Create route for"'

# 認証・セッション
alias ccauth='claude code "Create authentication for"'
alias ccsession='claude code "Create session handling for"'

# データベース
alias ccdb='claude --context db/db.json,src/utils/database.js'
alias ccmodel='claude code "Create model for"'
alias ccseed='claude code "Create seed data for"'

# フロントエンド
alias ccjs='claude code "Create JavaScript for"'
alias cccss='claude code "Create CSS for"'
alias ccform='claude code "Create form handling for"'

# テスト
alias cctest='claude code "Create tests for"'
alias cctest-view='claude code "Create view tests for"'
alias cctest-api='claude code "Create API tests for"'

# === 複合コマンド ===
# 新機能開発フロー（画面付き）
alias ccfeature='f() { ccmodel "$1" && ccapi "$1" && ccweb "$1" && ccview "$1" && cctest "$1"; }; f'

# 認証機能フロー
alias ccauth-full='f() { ccauth "$1" && ccview "login" && ccview "dashboard" && cctest "auth"; }; f'
```

---

## 🎯 品質管理

### 1. コード品質

```bash
# EJS テンプレート レビュー
claude review src/views/ --prompt "
Review EJS templates for:
- Security (XSS prevention)
- Accessibility
- SEO optimization
- Performance
- Maintainability
- Template organization
"

# セッション管理レビュー
claude review src/middlewares/auth.js --prompt "
Review session management for:
- Security vulnerabilities
- Session fixation prevention
- Proper logout handling
- CSRF protection
- Session timeout
"
```

### 2. セキュリティ監査

```bash
# セキュリティ監査
claude review --prompt "
Security audit for EJS monolith:
- XSS prevention in templates
- CSRF protection
- Session security
- Input validation
- SQL injection (if applicable)
- File upload security
- Authentication bypass
- Authorization flaws
"
```

---

## 🚀 本番運用

### 1. パフォーマンス最適化

```bash
# EJS キャッシュ設定
claude code "Create EJS caching strategy" --prompt "
EJS performance optimization:
- Template caching in production
- Static asset caching
- Session store optimization
- Database query optimization
- Memory usage monitoring
"
```

### 2. 監視とログ

```bash
# ログ設定
claude code "Create logging strategy" --prompt "
Comprehensive logging:
- Request/response logging
- Authentication events
- Error tracking
- Performance metrics
- Security events
- Session management logs
"
```

---

## 📚 技術スタック差分

| 区分        | API専用版                    | **モノリシック EJS 版**                             |
| --------- | ------------------------ | -------------------------------------------- |
| ビューエンジン   | なし（API 専用）               | **EJS** ＋ express‑ejs‑layouts（共通レイアウト）       |
| 静的配信      | `express.static`         | 同左。`/public` 配下に CSS/JS/画像                   |
| 認証 UI     | Postman/Swagger          | EJS で簡易ログイン画面（フォーム POST）                     |
| OpenAPI   | openapi-backend          | 任意。PoC では **/api/** プレフィックスのみに適用可            |
| MVC 階層    | REST Controller オンリー     | `views/`, `viewControllers/` を追加（画面用コントローラ）  |
| セッション管理   | JWT トークン                 | express-session + Cookie                     |
| フロントエンド連携 | 外部 SPA                   | EJS + Ajax（プログレッシブエンハンスメント）                  |

> **ポイント**
>
> * **API と画面の Router を分離**し、URL 空間で衝突させない（例：`/api/users` と `/users`）。
> * テスト資産（Jest/Supertest）は API 用にそのまま流用可能。
> * 将来マイクロサービスへ切り出す際、画面用コントローラを Next.js などに差し替えやすい設計。

---

## 📋 開発ステップ

### 1. 最小構成での起動確認

```bash
# 基本サーバー構築
make setup
make dev

# ルート / での EJS 描画確認
curl http://localhost:3000/
```

### 2. セッション認証の実装

```bash
# ログイン画面の実装
ccview login
ccauth-full user

# セッション動作確認
curl -c cookies.txt -X POST http://localhost:3000/login -d "email=test@example.com&password=test"
curl -b cookies.txt http://localhost:3000/dashboard
```

### 3. API 併設

```bash
# API エンドポイント追加
ccapi user
cctest-api user

# API 動作確認
curl http://localhost:3000/api/users
```

### 4. Ajax 連携

```bash
# フロントエンド JavaScript
ccjs "user management"
ccform "user forms"

# 統合テスト
make test
```

---

これで **単一サーバーで画面とAPIを提供するモノリシック構成** が完成し、将来の分割も見据えた柔軟な設計となります。