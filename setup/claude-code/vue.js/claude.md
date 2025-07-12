# Claude Code ドキュメント - Vue.js 3 フロントエンド専用版

Vue.js 3 をモダンフロントエンド専用フレームワークとして活用する Claude Code 完全ガイド。バックエンドAPIは別途用意されている前提で、TypeScriptによる型安全なフロントエンド開発に特化。

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
- **Framework**: Vue.js 3.x (Composition API)
- **Language**: TypeScript 5.x
- **パッケージマネージャー**: pnpm
- **ビルドツール**: Vite

#### UI・スタイリング
- **UI Framework**: Vue 3 (Composition API)
- **CSS Framework**: Tailwind CSS 3.x / UnoCSS
- **UIライブラリ**: Quasar / Vuetify / PrimeVue / Element Plus
- **アイコン**: Iconify / Vue Icon
- **アニメーション**: @vueuse/motion / GSAP

#### 状態管理・データフェッチ
- **状態管理**: Pinia / Vuex
- **APIクライアント**: Axios / Fetch API
- **データフェッチ**: VueUse / TanStack Query
- **リアルタイム**: Socket.io / WebSocket / Server-Sent Events
- **キャッシュ**: TanStack Query / Pinia Persistor

#### 開発ツール・品質管理
- **Linting**: ESLint + @vue/eslint-config-typescript
- **フォーマット**: Prettier
- **Git Hooks**: husky + lint-staged
- **コミット規約**: Conventional Commits
- **タスクランナー**: Make / npm scripts

#### テスト・品質保証
- **単体テスト**: Vitest / Jest
- **コンポーネントテスト**: @testing-library/vue / Vue Test Utils
- **E2Eテスト**: Playwright / Cypress
- **ビジュアルテスト**: Percy / Chromatic
- **型チェック**: vue-tsc

---

## 🚀 プロジェクトセットアップ

### 初期化

```bash
# プロジェクト作成
mkdir vue3-frontend && cd vue3-frontend
claude init
```

### package.json 生成

```bash
claude code "Generate Vue 3 frontend package.json" -o package.json --prompt "
Create package.json for Vue 3 frontend:
- Vue 3.x latest, TypeScript + vue-tsc
- Vite bundler, Vue Router, Pinia state management
- Tailwind CSS / UnoCSS, UI components (Quasar/Vuetify/Element Plus)
- VueUse utilities, Axios/Fetch for API
- Testing: Vitest, Playwright, Vue Test Utils
- Dev tools: ESLint, Prettier
- Plugins: Vue i18n, Vue DevTools
"
```

### プロジェクト構造

```
project-root/
├── src/
│   ├── components/         # UIコンポーネント
│   │   ├── common/        # 共通コンポーネント
│   │   ├── layout/        # レイアウト部品
│   │   ├── features/      # 機能別コンポーネント
│   │   └── ui/           # 基礎UIコンポーネント
│   ├── composables/       # Composition API
│   │   ├── api/          # API関連
│   │   ├── auth/         # 認証関連
│   │   └── utils/        # ユーティリティ
│   ├── views/             # ページコンポーネント
│   ├── router/            # Vue Router設定
│   ├── stores/            # Pinia stores
│   ├── plugins/           # Vue plugins
│   ├── assets/            # 静的アセット
│   ├── types/             # TypeScript型定義
│   ├── utils/             # ユーティリティ関数
│   ├── locales/           # i18n言語ファイル
│   ├── App.vue            # ルートコンポーネント
│   └── main.ts            # エントリーポイント
├── public/                # 公開アセット
├── tests/
│   ├── unit/, components/, e2e/
├── 設定ファイル群
│   ├── vite.config.ts, tsconfig.json
│   ├── tailwind.config.ts, vitest.config.ts
│   └── playwright.config.ts, Makefile
```

### .claude.json 設定

```json
{
  "project": "vue3-frontend",
  "type": "frontend",
  "language": "typescript",
  "framework": "vue3",
  "api": "external",
  "context": {
    "includePaths": ["src", "tests"],
    "excludePatterns": ["node_modules", "dist", "coverage"],
    "additionalContext": [
      "vite.config.ts",
      "package.json",
      "tsconfig.json",
      "tailwind.config.ts",
      ".env.example"
    ]
  },
  "api": {
    "baseUrl": "process.env.VITE_API_URL",
    "authEndpoint": "/api/auth",
    "dataEndpoint": "/api"
  },
  "ui": {
    "framework": "tailwindcss",
    "components": "quasar",
    "icons": "iconify",
    "animations": "@vueuse/motion"
  },
  "templates": {
    "page": "Create Vue 3 page component with TypeScript and data fetching",
    "component": "Create Vue 3 component with TypeScript setup syntax",
    "composable": "Create typed composable for API integration",
    "store": "Create Pinia store with TypeScript and API integration",
    "view": "Create Vue view component with router integration",
    "test": "Create Vitest test with TypeScript"
  },
  "codeStyle": {
    "quotes": "single",
    "semi": false,
    "vueStyle": "setup-script",
    "importOrder": ["vue", "vue-router", "pinia", "@/", "./"]
  }
}
```

---

## 🔧 開発フロー

### Makefile 主要タスク

```makefile
# 基本コマンド
install     # 依存関係インストール
dev         # Vite開発サーバー起動
build       # プロダクションビルド
test        # 全テスト実行
lint        # ESLintコード品質チェック

# 開発支援
typecheck   # vue-tsc型チェック
format      # Prettierコード整形
analyze     # Viteバンドル分析
lighthouse  # パフォーマンス監査

# テスト種別
test:unit   # Vitest単体テスト
test:e2e    # Playwright E2Eテスト
coverage    # テストカバレッジ

# ビルド種別
build:prod  # プロダクションビルド
preview     # ビルドプレビュー
build:lib   # ライブラリビルド

# デプロイ
deploy:vercel  # Vercelデプロイ
deploy:netlify # Netlifyデプロイ
deploy:gh-pages # GitHub Pagesデプロイ
```

---

## 🛠️ 実装ガイド

### コア機能

#### Vite設定

```bash
# vite.config.ts
claude code "Create Vue 3 Vite config" -o vite.config.ts --prompt "
Vite config: Vue 3 plugin, TypeScript, path aliases, build optimization, dev server proxy, PWA plugin, environment variables
"

#### API統合層

```bash
# APIクライアント
claude code "Create API client" -o src/utils/api.ts --prompt "Axios設定、認証トークン、インターセプター、エラーハンドリング、リトライ機能付きAPIクライアント"

# API Composables
claude code "Create API composables" -o src/composables/useApi.ts --prompt "useApi、useAuth、usePagination、useRealtime等のComposables"

# 型定義
claude code "Create API types" -o src/types/api/index.ts --prompt "レスポンス型、エラー型、ページネーション型、共通モデル型"
```

#### 認証システム

```bash
# 認証ストア
claude code "Create auth store" -o src/stores/auth.ts --prompt "ユーザー状態管理、ログイン/ログアウト、トークン管理、権限チェック機能"

# 認証Composable
claude code "Create auth composable" -o src/composables/useAuth.ts --prompt "認証メソッド、ユーザー状態、権限ヘルパー、ルートガード"

# ルーターガード
claude code "Create router guards" -o src/router/guards.ts --prompt "ルート保護、ロールベースアクセス、リダイレクト処理、6ルーターナビゲーションガード"
```

#### UIコンポーネント

```bash
# 基礎コンポーネント
claude code "Create base button" -o src/components/ui/BaseButton.vue --prompt "TypeScript props、バリアント、ローディング状態、アイコン、アクセシビリティ対応ボタン"

# フォーム
claude code "Create form input" -o src/components/ui/FormInput.vue --prompt "v-model、バリデーション、エラー表示、アクセシビリティ対応入力フィールド"

# データ表示
claude code "Create data table" -o src/components/ui/DataTable.vue --prompt "ソート、フィルタ、ページネーション、選択機能付きデータテーブル"
```

#### ページ実装

```bash
# ホームページ
claude code "Create home view" -o src/views/HomeView.vue --prompt "ヒーローセクション、機能紹介、データフェッチ、SEOメタ、レスポンシブ対応ホームページ"

# ダッシュボード
claude code "Create dashboard view" -o src/views/DashboardView.vue --prompt "統計概要、チャート、リアルタイム更新、ウィジェットシステム付きダッシュボード"

# プロフィール
claude code "Create profile view" -o src/views/ProfileView.vue --prompt "ユーザーIDパラメータ、編集機能、画像アップロード、フォームバリデーション付きプロフィール"
```

#### 状態管理

```bash
# アプリケーションストア
claude code "Create app store" -o src/stores/app.ts --prompt "グローバルローディング、通知、モーダル、サイドバー、テーマ設定管理ストア"

# UIストア
claude code "Create UI store" -o src/stores/ui.ts --prompt "モーダル、ドロワー、トースト、オーバーレイ、確認ダイアログ管理ストア"
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
claude code "Create component library index" -o src/components/index.ts --prompt "
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
claude code "Create image component" -o src/components/ui/OptimizedImage.vue --prompt "
Image component with:
- Native lazy loading
- Intersection Observer
- Placeholder blur
- Responsive sizes
- WebP support
- Error handling
- Accessibility
"

# 遅延読み込み
claude code "Create lazy wrapper" -o src/components/utils/LazyLoad.vue --prompt "
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
alias vf='cd ~/projects/vue3-frontend'
alias vfd='make dev'
alias vfb='make build'
alias vft='make test'
alias vfl='make lint'

# Claude Code コンテキスト
alias ccvf='claude --context vite.config.ts,package.json,tsconfig.json'
alias ccvfull='claude --directory src --recursive'
```

### コンポーネント作成

```bash
# コンポーネント関連
alias ccvcomp='claude code "Create Vue 3 component with TypeScript"'
alias ccvui='claude code "Create UI component"'
alias ccvform='claude code "Create form component with validation"'
alias ccvtable='claude code "Create data table component"'

# ビュー・レイアウト
alias ccvview='claude code "Create Vue 3 view with router integration"'
alias ccvlayout='claude code "Create responsive layout component"'

# Composables & Stores
alias ccvuse='claude code "Create composable for"'
alias ccvstore='claude code "Create Pinia store for"'
alias ccvapi='claude code "Create API integration for"'
```

### テスト・最適化

```bash
# テスト
alias ccvtest='claude code "Create component test for"'
alias ccve2e='claude code "Create E2E test for"'

# 最適化
alias ccvperf='claude review --prompt "Optimize Vue 3 performance"'
alias ccvseo='claude review --prompt "Improve SPA SEO"'
alias ccvbundle='claude review --prompt "Reduce Vite bundle size"'
```

### 統合フロー

```bash
# 新規ビュー作成
alias ccnewview='f() {
  ccvview "$1" && ccvstore "$1" && ccvapi "$1" && ccvtest "$1"
}; f'

# UIコンポーネント作成
alias ccnewui='f() {
  ccvui "$1" && ccvtest "$1"
}; f'

# 機能実装
alias ccvfeature='f() {
  echo "Implementing: $1"
  ccvapi "$1" && ccvstore "$1" && ccvview "$1" && ccvtest "$1"
}; f'
```

---

## 🎯 ベストプラクティス

### API統合パターン

```bash
# API統合レビュー
claude review src/composables/api --prompt "エラーハンドリング一貫性、型安全性、ローディング状態、キャッシュ戦略、リトライ、トークンリフレッシュ"

# データフェッチパターン
claude code "Create data fetching guide" --prompt "SPAデータフェッチ、Composition APIパターン、キャッシュ戦略、楽観的更新、リアルタイム更新、TanStack Query統合"
```

### パフォーマンス最適化

```bash
# Core Web Vitals最適化
claude review --prompt "Core Web Vitals最適化: LCP, FID, CLS, TTI, Viteバンドルサイズ"

# Vue.jsパフォーマンス
claude review src/views/ --prompt "Vue 3パフォーマンス最適化、動的インポート、lazy loading、keep-alive、コンポーネントメモ化"

# アクセシビリティ
claude review src/components --prompt "ARIAラベル、キーボードナビ、スクリーンリーダー、コントラスト、フォーカス管理"
```

---

## 📚 ドキュメント生成

```bash
# README作成
claude docs "Generate Vue 3 frontend README" --prompt "プロジェクト概要、Vue 3技術スタック、Viteセットアップ手順、開発ワークフロー、API統合ガイド、デプロイガイド"

# コンポーネントドキュメント
claude docs "Generate Vue component docs" --prompt "全VueコンポーネントのProps/Emits/Slots、Composition API使用例、スタイリングオプション、アクセシビリティノート、パフォーマンスティップス"

# API統合ガイド
claude docs "Create Vue API integration guide" --prompt "Vue 3認証設定、Axiosクライアント設定、エラーハンドリング、TypeScript型生成、モックデータ設定、Vitestテスト戦略"
```
