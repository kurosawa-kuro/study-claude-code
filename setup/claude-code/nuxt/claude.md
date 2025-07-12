# Claude Code ドキュメント - Nuxt 3 フロントエンド専用版

Nuxt 3 をモダンフロントエンド専用フレームワークとして活用する Claude Code 完全ガイド。バックエンドAPIは別途用意されている前提で、TypeScriptによる型安全なフロントエンド開発に特化。

## 📑 目次

1. [技術スタック](#-技術スタック)
2. [プロジェクトセットアップ](#-プロジェクトセットアップ)
3. [開発フロー](#-開発フロー)
4. [実装ガイド](#-実装ガイド)
   - [コア機能](#コア機能)
   - [認証システム](#認証システム)
   - [UIコンポーネント](#uiコンポーネント)
   - [ページ実装](#ページ実装)
   - [状態管理](#状態管理)
5. [テスト戦略](#-テスト戦略)
6. [UI/UX開発](#-uiux開発)
7. [エイリアス集](#-エイリアス集)
8. [ベストプラクティス](#-ベストプラクティス)

---

## 📋 プロジェクト概要

### 🛠️ 技術スタック

#### コアフレームワーク
- **Runtime**: Node.js 18.x+
- **Framework**: Nuxt 3.x (SSR/SSG/SPA)
- **Language**: TypeScript 5.x
- **パッケージマネージャー**: pnpm
- **ビルドツール**: Vite

#### UI・スタイリング
- **UI Framework**: Vue 3 (Composition API)
- **CSS Framework**: Tailwind CSS 3.x / UnoCSS
- **UIライブラリ**: Nuxt UI / Shadcn-vue / PrimeVue
- **アイコン**: Nuxt Icon / Iconify
- **アニメーション**: @vueuse/motion / auto-animate

#### 状態管理・データフェッチ
- **状態管理**: Pinia
- **APIクライアント**: ofetch / $fetch
- **データフェッチ**: useFetch / useAsyncData
- **リアルタイム**: WebSocket / Server-Sent Events
- **キャッシュ**: Nuxt Cache API

#### 開発ツール・品質管理
- **Linting**: ESLint + @nuxt/eslint-config
- **フォーマット**: Prettier
- **Git Hooks**: husky + lint-staged
- **コミット規約**: Conventional Commits
- **タスクランナー**: Make

#### テスト・品質保証
- **単体テスト**: Vitest + @nuxt/test-utils
- **コンポーネントテスト**: @testing-library/vue
- **E2Eテスト**: Playwright / Cypress
- **ビジュアルテスト**: Percy / Chromatic
- **型チェック**: vue-tsc

---

## 🚀 プロジェクトセットアップ

### 初期化

```bash
# プロジェクト作成
mkdir nuxt3-frontend && cd nuxt3-frontend
claude init
```

### package.json 生成

```bash
claude code "Generate Nuxt 3 frontend package.json" -o package.json --prompt "
Create package.json for Nuxt 3 frontend:
- Nuxt 3.x latest, TypeScript + vue-tsc
- Tailwind CSS / UnoCSS, Nuxt UI components  
- Pinia, VueUse, ofetch
- Testing: Vitest, Playwright
- Dev tools: ESLint, Prettier
- Modules: @nuxt/image, @nuxtjs/color-mode, @nuxtjs/google-fonts, @vueuse/nuxt, @pinia/nuxt, @nuxtjs/i18n
"
```

### プロジェクト構造

```
project-root/
├── app/
│   ├── components/         # UIコンポーネント
│   │   ├── common/        # 共通コンポーネント
│   │   ├── layout/        # レイアウト部品
│   │   ├── features/      # 機能別コンポーネント
│   │   └── ui/           # 基礎UIコンポーネント
│   ├── composables/       # Composition API
│   │   ├── api/          # API関連
│   │   ├── auth/         # 認証関連
│   │   └── utils/        # ユーティリティ
│   ├── layouts/, pages/, middleware/, plugins/
│   └── app.vue
├── assets/, public/, stores/, types/, utils/, locales/
├── tests/
│   ├── unit/, components/, e2e/
├── 設定ファイル群
│   ├── nuxt.config.ts, tsconfig.json
│   ├── tailwind.config.ts, vitest.config.ts
│   └── playwright.config.ts, Makefile
```

### .claude.json 設定

```json
{
  "project": "nuxt3-frontend",
  "type": "frontend",
  "language": "typescript",
  "framework": "nuxt3",
  "api": "external",
  "context": {
    "includePaths": ["app", "stores", "types", "utils", "tests"],
    "excludePatterns": ["node_modules", ".nuxt", ".output", "dist", "coverage"],
    "additionalContext": [
      "nuxt.config.ts",
      "package.json",
      "tsconfig.json",
      "tailwind.config.ts",
      ".env.example"
    ]
  },
  "api": {
    "baseUrl": "process.env.NUXT_PUBLIC_API_URL",
    "authEndpoint": "/api/auth",
    "dataEndpoint": "/api"
  },
  "ui": {
    "framework": "tailwindcss",
    "components": "nuxt-ui",
    "icons": "@nuxt/icon",
    "animations": "@vueuse/motion"
  },
  "templates": {
    "page": "Create Nuxt 3 page with TypeScript and data fetching",
    "component": "Create Vue 3 component with TypeScript setup syntax",
    "composable": "Create typed composable for API integration",
    "store": "Create Pinia store with TypeScript and API integration",
    "layout": "Create responsive layout with TypeScript",
    "test": "Create Vitest test with TypeScript"
  },
  "codeStyle": {
    "quotes": "single",
    "semi": false,
    "vueStyle": "setup-script",
    "importOrder": ["vue", "nuxt", "@/", "~/", "."]
  }
}
```

---

## 🔧 開発フロー

### Makefile 主要タスク

```makefile
# 基本コマンド
install     # 依存関係インストール
dev         # 開発サーバー起動
build       # プロダクションビルド
test        # 全テスト実行
lint        # コード品質チェック

# 開発支援
typecheck   # 型チェック
format      # コード整形
analyze     # バンドル分析
lighthouse  # パフォーマンス監査

# テスト種別
test:unit   # 単体テスト
test:e2e    # E2Eテスト
coverage    # カバレッジ

# ビルド種別
build:ssr   # SSRビルド
build:spa   # SPAビルド
build:static # 静的サイト生成

# デプロイ
deploy:vercel  # Vercelデプロイ
deploy:netlify # Netlifyデプロイ
```

---

## 🛠️ 実装ガイド

### コア機能

#### Nuxt設定

```bash
# nuxt.config.ts
claude code "Create frontend-focused Nuxt config" -o nuxt.config.ts --prompt "
Nuxt 3 config: External API, Runtime config, SSR/SSG optimization, Image/Font optimization, PWA, SEO, Security headers, Modules (Tailwind, Pinia, Color mode, i18n, VueUse)
"

#### API統合層

```bash
# APIクライアント
claude code "Create API client" -o utils/api.ts --prompt "ofetch設定、認証トークン、エラーハンドリング、リトライ機能付きAPIクライアント"

# API Composables
claude code "Create API composables" -o app/composables/useApi.ts --prompt "useApi、useAuth、usePagination、useRealtime等のComposables"

# 型定義
claude code "Create API types" -o types/api/index.ts --prompt "レスポンス型、エラー型、ページネーション型、共通モデル型"
```

#### 認証システム

```bash
# 認証ストア
claude code "Create auth store" -o stores/auth.ts --prompt "ユーザー状態管理、ログイン/ログアウト、トークン管理、権限チェック機能"

# 認証Composable
claude code "Create auth composable" -o app/composables/useAuth.ts --prompt "認証メソッド、ユーザー状態、権限ヘルパー、ルートガード"

# 認証ミドルウェア
claude code "Create auth middleware" -o app/middleware/auth.ts --prompt "ルート保護、ロールベースアクセス、リダイレクト処理"
```

#### UIコンポーネント

```bash
# 基礎コンポーネント
claude code "Create base button" -o app/components/ui/BaseButton.vue --prompt "TypeScript props、バリアント、ローディング状態、アイコン、アクセシビリティ対応ボタン"

# フォーム
claude code "Create form input" -o app/components/ui/FormInput.vue --prompt "v-model、バリデーション、エラー表示、アクセシビリティ対応入力フィールド"

# データ表示
claude code "Create data table" -o app/components/ui/DataTable.vue --prompt "ソート、フィルタ、ページネーション、選択機能付きデータテーブル"
```

#### ページ実装

```bash
# ホームページ
claude code "Create home page" -o app/pages/index.vue --prompt "ヒーローセクション、機能紹介、データフェッチ、SEO、レスポンシブ対応ホームページ"

# ダッシュボード
claude code "Create dashboard" -o app/pages/dashboard/index.vue --prompt "統計概要、チャート、リアルタイム更新、ウィジェットシステム付きダッシュボード"

# プロフィール
claude code "Create profile page" -o app/pages/profile/[id].vue --prompt "動的ルーティング、編集機能、画像アップロード、フォームバリデーション付きプロフィール"
```

#### 状態管理

```bash
# アプリケーションストア
claude code "Create app store" -o stores/app.ts --prompt "グローバルローディング、通知、モーダル、サイドバー、テーマ設定管理ストア"

# UIストア
claude code "Create UI store" -o stores/ui.ts --prompt "モーダル、ドロワー、トースト、オーバーレイ、確認ダイアログ管理ストア"
```

---

## 🧪 テスト戦略

### コンポーネントテスト

```bash
# コンポーネントテスト設定
claude code "Create component test utils" -o tests/utils/component.ts --prompt "
Test utilities:
- Render helpers
- Mock providers
- User event helpers
- Accessibility checks
- Snapshot utilities
- Custom matchers
"

# コンポーネントテスト例
claude code "Create button component tests" -o tests/components/BaseButton.test.ts --prompt "
Button tests:
- Props validation
- Event emissions
- Slot content
- Accessibility
- Keyboard interaction
- Visual states
- Loading behavior
"
```

### E2Eテスト

```bash
# 認証フローE2E
claude code "Create auth E2E tests" -o tests/e2e/auth.spec.ts --prompt "
Auth flow tests:
- Login success/failure
- Registration flow
- Password reset
- Social login
- Remember me
- Auto logout
- Protected routes
"

# ユーザージャーニーE2E
claude code "Create user journey tests" -o tests/e2e/user-journey.spec.ts --prompt "
User journey:
- Landing page
- Sign up
- Onboarding
- Dashboard usage
- Profile update
- Settings change
- Logout
"
```

---

## 🎨 UI/UX開発

### デザインシステム

```bash
# デザイントークン
claude code "Create design tokens" -o assets/css/tokens.css --prompt "
Design tokens:
- Color palette
- Typography scale
- Spacing system
- Border radius
- Shadows
- Animations
- Breakpoints
CSS variables + Tailwind config
"

# コンポーネントライブラリ
claude code "Create component library index" -o app/components/index.ts --prompt "
Export all components:
- Organized by category
- TypeScript exports
- Props documentation
- Usage examples
"
```

### パフォーマンス最適化

```bash
# 画像最適化
claude code "Create image component" -o app/components/ui/OptimizedImage.vue --prompt "
Image component with:
- Nuxt Image integration
- Lazy loading
- Placeholder blur
- Responsive sizes
- WebP support
- Error handling
- Accessibility
"

# 遅延読み込み
claude code "Create lazy wrapper" -o app/components/utils/LazyLoad.vue --prompt "
Lazy loading wrapper:
- Intersection Observer
- Loading placeholder
- Error boundary
- Retry logic
- Progressive enhancement
"
```

---

## 🗺️ エイリアス集

### 基本コマンド

```bash
# ~/.bashrc or ~/.zshrc に追加

# プロジェクトナビゲーション
alias nf='cd ~/projects/nuxt3-frontend'
alias nfd='make dev'
alias nfb='make build'
alias nft='make test'
alias nfl='make lint'

# Claude Code コンテキスト
alias ccnf='claude --context nuxt.config.ts,package.json,tsconfig.json'
alias ccnfull='claude --directory app,stores,types --recursive'
```

### コンポーネント作成

```bash
# コンポーネント関連
alias ccncomp='claude code "Create Vue component with TypeScript"'
alias ccnui='claude code "Create UI component"'
alias ccnform='claude code "Create form component with validation"'
alias ccntable='claude code "Create data table component"'

# ページ・レイアウト
alias ccnpage='claude code "Create Nuxt 3 page with data fetching"'
alias ccnlayout='claude code "Create responsive layout"'

# Composables & Stores
alias ccnuse='claude code "Create composable for"'
alias ccnstore='claude code "Create Pinia store for"'
alias ccnapi='claude code "Create API integration for"'
```

### テスト・最適化

```bash
# テスト
alias ccntest='claude code "Create component test for"'
alias ccne2e='claude code "Create E2E test for"'

# 最適化
alias ccnperf='claude review --prompt "Optimize performance"'
alias ccnseo='claude review --prompt "Improve SEO"'
alias ccnbundle='claude review --prompt "Reduce bundle size"'
```

### 統合フロー

```bash
# 新規ページ作成
alias ccnewpage='f() {
  ccnpage "$1" && ccnstore "$1" && ccnapi "$1" && ccntest "$1"
}; f'

# UIコンポーネント作成
alias ccnewui='f() {
  ccnui "$1" && ccntest "$1"
}; f'

# 機能実装
alias ccnfeature='f() {
  echo "Implementing: $1"
  ccnapi "$1" && ccnstore "$1" && ccnpage "$1" && ccntest "$1"
}; f'
```

---

## 🎯 ベストプラクティス

### API統合パターン

```bash
# API統合レビュー
claude review app/composables/api --prompt "エラーハンドリング一貫性、型安全性、ローディング状態、キャッシュ戦略、リトライ、トークンリフレッシュ"

# データフェッチパターン
claude code "Create data fetching guide" --prompt "SSR/クライアントサイドフェッチ、ハイブリッドレンダリング、キャッシュ戦略、楽観的更新、リアルタイム更新"
```

### パフォーマンス最適化

```bash
# Core Web Vitals最適化
claude review --prompt "Core Web Vitals最適化: LCP, FID, CLS, TTI, バンドルサイズ"

# レンダリング戦略
claude review pages/ --prompt "SSR/SSG/SPA最適化、動的インポート、プリフェッチ、画像最適化"

# アクセシビリティ
claude review app/components --prompt "ARIAラベル、キーボードナビ、スクリーンリーダー、コントラスト、フォーカス管理"
```

---

## 📚 ドキュメント生成

```bash
# README作成
claude docs "Generate frontend README" --prompt "プロジェクト概要、技術スタック、セットアップ手順、開発ワークフロー、API統合ガイド、デプロイガイド"

# コンポーネントドキュメント
claude docs "Generate component docs" --prompt "全コンポーネントのProps/Events/Slots、使用例、スタイリングオプション、アクセシビリティノート、パフォーマンスティップス"

# API統合ガイド
claude docs "Create API integration guide" --prompt "認証設定、APIクライアント設定、エラーハンドリング、型生成、モックデータ設定、テスト戦略"
```
