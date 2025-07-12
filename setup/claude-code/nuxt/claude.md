# Claude Code ドキュメント - Nuxt 3 フロントエンド専用版

## 📋 プロジェクト概要

Nuxt 3 をモダンフロントエンド専用フレームワークとして活用する Claude Code 完全ガイド。バックエンドAPIは別途用意されている前提で、TypeScriptによる型安全なフロントエンド開発に特化。

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

## 🚀 プロジェクト初期化

### プロジェクトセットアップ

```bash
# プロジェクト作成
mkdir nuxt3-frontend && cd nuxt3-frontend
claude init

# Nuxt 3 フロントエンド用 package.json
claude code "Generate Nuxt 3 frontend package.json" -o package.json --prompt "
Create package.json for Nuxt 3 frontend:
- Nuxt 3.x latest
- TypeScript + vue-tsc
- Tailwind CSS / UnoCSS
- Nuxt UI components
- Pinia for state management
- VueUse composables
- ofetch for API calls
- Testing tools (Vitest, Playwright)
- Development tools (ESLint, Prettier)
- Nuxt modules:
  - @nuxt/image
  - @nuxtjs/color-mode
  - @nuxtjs/google-fonts
  - @vueuse/nuxt
  - @pinia/nuxt
  - @nuxtjs/i18n
- Scripts: dev, build, generate, preview, typecheck, test, lint
"
```

### プロジェクト構造

```bash
# フロントエンド特化型構造
claude code "Generate Nuxt 3 frontend project structure" --prompt "
Create frontend-focused structure:
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
│   ├── layouts/          # レイアウト
│   ├── pages/            # ページコンポーネント
│   ├── middleware/       # ルートミドルウェア
│   ├── plugins/          # Nuxtプラグイン
│   └── app.vue          # ルートコンポーネント
├── assets/               # アセット
│   ├── css/             # グローバルCSS
│   ├── images/          # 画像
│   └── fonts/           # フォント
├── public/              # 静的ファイル
├── stores/              # Pinia ストア
├── types/               # TypeScript型定義
│   ├── api/            # API型定義
│   ├── models/         # データモデル
│   └── utils/          # ユーティリティ型
├── utils/               # ユーティリティ関数
├── locales/             # 多言語ファイル
├── tests/               # テストファイル
│   ├── unit/           # 単体テスト
│   ├── components/     # コンポーネントテスト
│   └── e2e/           # E2Eテスト
├── .env.example         # 環境変数テンプレート
├── nuxt.config.ts       # Nuxt設定
├── tsconfig.json        # TypeScript設定
├── tailwind.config.ts   # Tailwind設定
├── vitest.config.ts     # Vitest設定
├── playwright.config.ts # Playwright設定
├── Makefile            # タスク定義
└── README.md           # ドキュメント
"
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

## 📝 Makefile - フロントエンドタスク管理

```bash
# Makefile 生成
claude code "Create Nuxt 3 frontend Makefile" -o Makefile --prompt "
Create frontend-focused Makefile:

# === Configuration ===
PNPM := pnpm
NODE_ENV ?= development
PORT ?= 3000
API_URL ?= http://localhost:4000

# === Primary Commands ===
help: Command list
install: Install dependencies
dev: Development server
build: Production build
preview: Preview build
test: Run all tests
deploy: Deploy to hosting

# === Development ===
dev:host: Network accessible dev
dev:https: HTTPS dev server
dev:mobile: Mobile testing setup
typecheck: Type checking
lint: Linting
format: Code formatting

# === Build Variants ===
build:ssr: SSR build
build:spa: SPA build
build:static: Full static generation
analyze: Bundle analysis
lighthouse: Performance audit

# === Testing ===
test:unit: Unit tests
test:component: Component tests
test:e2e: E2E tests
test:visual: Visual regression
test:a11y: Accessibility tests
coverage: Coverage report

# === API Mocking ===
mock:server: Start mock API
mock:generate: Generate mock data

# === UI Development ===
storybook: Component explorer
icons:browse: Icon browser
colors:preview: Color palette

# === Deployment ===
deploy:vercel: Vercel deployment
deploy:netlify: Netlify deployment
deploy:preview: Preview deployment

# === Utilities ===
clean: Clean artifacts
update: Update dependencies
env:check: Validate env vars
api:types: Generate API types
"
```

---

## 🔧 コア実装

### Nuxt設定（フロントエンド特化）

```bash
# nuxt.config.ts
claude code "Create frontend-focused Nuxt config" -o nuxt.config.ts --prompt "
Nuxt 3 config for frontend:
- External API configuration
- Runtime config for API URLs
- SSR/SSG optimization
- Image optimization
- Font optimization
- PWA configuration
- SEO defaults
- Performance settings
- Security headers (CSP)
- Modules configuration:
  - Tailwind/UnoCSS
  - Pinia
  - Color mode
  - i18n
  - VueUse
"
```

### API統合層

```bash
# APIクライアント設定
claude code "Create API client setup" -o utils/api.ts --prompt "
API client with:
- ofetch configuration
- Base URL from env
- Auth token handling
- Request/response interceptors
- Error handling
- Retry logic
- TypeScript generics
- Loading states
"

# API Composables
claude code "Create API composables" -o app/composables/useApi.ts --prompt "
API composables:
- useApi: Generic API caller
- useAuth: Authentication
- usePagination: Paginated data
- useInfiniteScroll: Infinite loading
- useRealtime: WebSocket/SSE
- useUpload: File uploads
All with TypeScript types
"

# 型定義生成
claude code "Create API type definitions" -o types/api/index.ts --prompt "
API types:
- Response wrappers
- Error types
- Pagination types
- Common models (User, etc)
- Request/Response DTOs
- Utility types
"
```

### 認証システム

```bash
# 認証ストア
claude code "Create auth store" -o stores/auth.ts --prompt "
Auth store with:
- User state management
- Login/logout actions
- Token management
- Refresh token logic
- Permission checking
- Remember me
- Social auth support
- TypeScript interfaces
"

# 認証Composable
claude code "Create auth composable" -o app/composables/useAuth.ts --prompt "
Auth composable:
- Login/logout methods
- User state
- Permission helpers
- Route guards
- Token refresh
- Auto logout
- Session management
"

# 認証ミドルウェア
claude code "Create auth middleware" -o app/middleware/auth.ts --prompt "
Auth middleware:
- Route protection
- Role-based access
- Guest only routes
- Redirect handling
- Token validation
"
```

### UIコンポーネント

```bash
# 基礎コンポーネント
claude code "Create base button component" -o app/components/ui/BaseButton.vue --prompt "
Button component with:
- TypeScript props
- Multiple variants
- Loading state
- Icons support
- Accessibility
- Keyboard navigation
- Size variations
- Disabled states
"

# フォームコンポーネント
claude code "Create form input component" -o app/components/ui/FormInput.vue --prompt "
Form input with:
- v-model support
- Validation display
- Error messages
- Label/placeholder
- Icons
- Different types
- Accessibility
- TypeScript types
"

# データ表示コンポーネント
claude code "Create data table component" -o app/components/ui/DataTable.vue --prompt "
Data table with:
- TypeScript generics
- Sorting
- Filtering
- Pagination
- Selection
- Actions
- Responsive design
- Loading states
"
```

### ページ実装

```bash
# ホームページ
claude code "Create home page" -o app/pages/index.vue --prompt "
Home page with:
- Hero section
- Feature showcase
- Data fetching
- Loading states
- Error handling
- SEO meta tags
- Responsive design
- Performance optimized
"

# ダッシュボード
claude code "Create dashboard" -o app/pages/dashboard/index.vue --prompt "
Dashboard with:
- Stats overview
- Charts integration
- Real-time updates
- Widget system
- Responsive grid
- Data fetching
- Error boundaries
"

# プロフィールページ
claude code "Create profile page" -o app/pages/profile/[id].vue --prompt "
Profile page with:
- Dynamic routing
- User data fetching
- Edit capabilities
- Image upload
- Form validation
- Tabs navigation
- Activity feed
"
```

### 状態管理

```bash
# アプリケーションストア
claude code "Create app store" -o stores/app.ts --prompt "
App store for:
- Global loading states
- Notifications/toasts
- Modal management
- Sidebar state
- Theme preferences
- Locale settings
- Breadcrumbs
"

# UIストア
claude code "Create UI store" -o stores/ui.ts --prompt "
UI store managing:
- Modal states
- Drawer states
- Toast notifications
- Loading overlays
- Confirmation dialogs
- Theme settings
"
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

## 📊 プロジェクト別エイリアス

```bash
# ~/.bashrc or ~/.zshrc に追加

# === 基本コマンド ===
alias nf='cd ~/projects/nuxt3-frontend'
alias nfd='make dev'
alias nfb='make build'
alias nft='make test'
alias nfl='make lint'

# === Claude Code - Nuxt Frontend ===
# コンテキスト
alias ccnf='claude --context nuxt.config.ts,package.json,tsconfig.json'
alias ccnfull='claude --directory app,stores,types --recursive'

# ページ・レイアウト
alias ccnpage='claude code "Create Nuxt 3 page with data fetching"'
alias ccnlayout='claude code "Create responsive layout"'
alias ccnmeta='claude code "Add SEO meta tags for"'

# コンポーネント
alias ccncomp='claude code "Create Vue component with TypeScript"'
alias ccnui='claude code "Create UI component"'
alias ccnform='claude code "Create form component with validation"'
alias ccntable='claude code "Create data table component"'

# Composables & Stores
alias ccnuse='claude code "Create composable for"'
alias ccnstore='claude code "Create Pinia store for"'
alias ccnapi='claude code "Create API integration for"'

# スタイリング
alias ccnstyle='claude code "Create Tailwind styles for"'
alias ccnanim='claude code "Add animations to"'
alias ccntheme='claude code "Create theme variant for"'

# テスト
alias ccntest='claude code "Create component test for"'
alias ccne2e='claude code "Create E2E test for"'
alias ccna11y='claude code "Add accessibility to"'

# 最適化
alias ccnperf='claude review --prompt "Optimize performance"'
alias ccnseo='claude review --prompt "Improve SEO"'
alias ccnbundle='claude review --prompt "Reduce bundle size"'

# === 複合フロー ===
# 新規ページ作成フロー
alias ccnewpage='f() {
  ccnpage "$1" &&
  ccnstore "$1" &&
  ccnapi "$1" &&
  ccntest "$1"
}; f'

# UIコンポーネント作成フロー
alias ccnewui='f() {
  ccnui "$1" &&
  ccntest "$1" &&
  ccnstyle "$1" &&
  claude code "Create Storybook story for $1"
}; f'

# 機能実装フロー
alias ccnfeature='f() {
  echo "Implementing feature: $1"
  ccnapi "$1" &&
  ccnstore "$1" &&
  ccnpage "$1" &&
  ccncomp "$1" &&
  ccntest "$1"
}; f'
```

---

## 🎯 ベストプラクティス

### API統合パターン

```bash
# API統合のベストプラクティス
claude review app/composables/api --prompt "
Review API integration for:
- Error handling consistency
- Type safety
- Loading state management
- Cache strategy
- Retry logic
- Token refresh handling
"

# データフェッチ最適化
claude code "Create data fetching patterns guide" --prompt "
Document patterns for:
- SSR data fetching
- Client-side fetching
- Hybrid rendering
- Cache strategies
- Optimistic updates
- Real-time subscriptions
"
```

### パフォーマンス最適化

```bash
# Core Web Vitals最適化
claude review --prompt "
Optimize for Core Web Vitals:
- Largest Contentful Paint
- First Input Delay
- Cumulative Layout Shift
- Time to Interactive
- Bundle size optimization
"

# レンダリング戦略
claude review pages/ --prompt "
Optimize rendering:
- SSR vs SSG vs SPA decisions
- Dynamic imports
- Prefetching strategies
- Image optimization
- Font loading
- Critical CSS
"
```

### アクセシビリティ

```bash
# アクセシビリティ監査
claude review app/components --prompt "
Accessibility audit:
- ARIA labels
- Keyboard navigation
- Screen reader support
- Color contrast
- Focus management
- Error announcements
"
```

---

## 📚 ドキュメント生成

### プロジェクトドキュメント

```bash
# README作成
claude docs "Generate frontend README" --prompt "
Include:
- Project overview
- Tech stack
- Setup instructions
- Development workflow
- API integration guide
- Deployment guide
- Component library
- Contributing guide
"

# コンポーネントドキュメント
claude docs "Generate component docs" --prompt "
Document all components:
- Props/Events/Slots
- Usage examples
- Styling options
- Accessibility notes
- Performance tips
"

# API統合ガイド
claude docs "Create API integration guide" --prompt "
Guide covering:
- Authentication setup
- API client configuration
- Error handling
- Type generation
- Mock data setup
- Testing strategies
"
```
