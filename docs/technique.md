# Claude Code ドキュメント

## 📋 概要

Claude Code は、Anthropic が提供するターミナルベースの AI コーディングアシスタントツールです。コマンドラインから直接 Claude と対話し、コード生成、デバッグ、リファクタリングなどの作業を効率化できます。

---

## 🚀 インストールと初期設定

### システム要件
- **OS**: Linux, macOS, Windows (WSL2)
- **Node.js**: 18.0.0 以上
- **RAM**: 4GB 以上推奨

### インストール方法

```bash
# npmを使用
npm install -g @anthropic/claude-code

# または yarn を使用
yarn global add @anthropic/claude-code

# または pnpm を使用
pnpm add -g @anthropic/claude-code
```

### 初期設定

```bash
# 初回セットアップ
claude init

# 対話形式で以下を設定:
# 1. APIキーの入力
# 2. デフォルトモデルの選択
# 3. 出力形式の設定
# 4. プロジェクトのデフォルト設定
```

---

## 📝 基本コマンド

### コマンド構文
```bash
claude [command] [options] [prompt]
```

### 主要コマンド一覧

| コマンド | 説明 | 使用例 |
|---------|------|--------|
| `claude init` | 初期設定ウィザード | `claude init` |
| `claude chat` | 対話モードを開始 | `claude chat` |
| `claude ask` | 単発の質問 | `claude ask "How to center a div?"` |
| `claude code` | コード生成 | `claude code "React login component"` |
| `claude fix` | エラー修正 | `claude fix error.log` |
| `claude review` | コードレビュー | `claude review src/` |
| `claude explain` | コード説明 | `claude explain app.js` |
| `claude test` | テスト生成 | `claude test userService.js` |
| `claude docs` | ドキュメント生成 | `claude docs --format markdown` |
| `claude config` | 設定変更 | `claude config --list` |

---

## ⚙️ オプション

### グローバルオプション

```bash
# ヘルプ表示
claude --help
claude -h

# バージョン表示
claude --version
claude -v

# 詳細出力
claude --verbose
claude -V

# JSON形式で出力
claude --json

# 出力をファイルに保存
claude --output file.txt
claude -o file.txt

# モデル指定
claude --model claude-opus-4
claude -m claude-opus-4

# コンテキストファイル指定
claude --context file.js
claude -c file.js

# ディレクトリ全体をコンテキストに
claude --directory ./src
claude -d ./src

# 再帰的にディレクトリを読み込み
claude --recursive
claude -r

# ファイルパターンで除外
claude --exclude "*.test.js,*.spec.js"
claude -e "*.test.js"

# ドライラン（実際には実行しない）
claude --dry-run

# キャッシュを使用しない
claude --no-cache

# タイムアウト設定（秒）
claude --timeout 30
claude -t 30
```

---

## 💻 使用例

### 基本的な使い方

```bash
# シンプルな質問
claude "What is the difference between let and const in JavaScript?"

# ファイルを読み込んで質問
claude --file app.js "Can you optimize this code?"

# 複数ファイルをコンテキストに
claude -c utils.js -c helpers.js "Refactor these utilities into a single module"

# ディレクトリ全体を解析
claude -d ./src --recursive "Find potential security issues"
```

### コード生成

```bash
# React コンポーネント生成
claude code "Create a React form component with validation"

# API エンドポイント生成
claude code "Express REST API for user management with JWT"

# データベーススキーマ生成
claude code "PostgreSQL schema for e-commerce platform"

# 生成したコードをファイルに保存
claude code "TypeScript interface for User" -o types/User.ts
```

### デバッグとエラー修正

```bash
# エラーログを送信して修正案を取得
cat error.log | claude fix

# TypeScript エラーを修正
npx tsc --noEmit 2>&1 | claude fix

# テスト失敗を解析
npm test 2>&1 | claude "Why is this test failing?"

# スタックトレースを解析
claude --file stacktrace.txt "Explain this error and how to fix it"
```

### コードレビュー

```bash
# 単一ファイルのレビュー
claude review src/auth.js

# プルリクエストの差分をレビュー
git diff main..feature | claude review

# 特定の観点でレビュー
claude review src/ --prompt "Check for security vulnerabilities"

# パフォーマンスに焦点を当てたレビュー
claude review -d ./api "Identify performance bottlenecks"
```

### ドキュメント生成

```bash
# README.md 生成
claude docs --format markdown -o README.md

# API ドキュメント生成
claude docs ./api --format openapi -o api-docs.yaml

# JSDoc コメント追加
claude explain ./src --add-comments

# 関数の説明を生成
claude explain utils.js --functions-only
```

---

## 🔧 設定ファイル

### グローバル設定 (~/.claude/config.json)

```json
{
  "apiKey": "your-api-key",
  "defaultModel": "claude-opus-4",
  "output": {
    "format": "markdown",
    "colorize": true,
    "lineNumbers": false
  },
  "context": {
    "maxFiles": 10,
    "maxFileSize": "1MB",
    "excludePatterns": ["node_modules", ".git", "dist", "build"]
  },
  "cache": {
    "enabled": true,
    "ttl": 3600,
    "location": "~/.claude/cache"
  }
}
```

### プロジェクト設定 (.claude.json)

```json
{
  "project": "my-nextjs-app",
  "language": "typescript",
  "framework": "nextjs",
  "context": {
    "includePaths": ["src", "pages", "components"],
    "excludePatterns": ["*.test.ts", "*.spec.ts"],
    "additionalContext": [
      "package.json",
      "tsconfig.json",
      ".eslintrc.js"
    ]
  },
  "templates": {
    "component": "Generate React component with TypeScript and Tailwind CSS",
    "api": "Create Next.js API route with error handling",
    "test": "Write Jest tests with React Testing Library"
  },
  "aliases": {
    "fix-ts": "fix TypeScript errors in",
    "make-responsive": "add responsive design to",
    "add-auth": "implement authentication for"
  }
}
```

---

## 🎯 高度な使用方法

### パイプラインとの統合

```bash
# Git diff をレビュー
git diff | claude review

# ビルドエラーを修正
npm run build 2>&1 | claude fix

# ログを解析
tail -f app.log | claude "Monitor for errors"

# 複数コマンドの組み合わせ
find . -name "*.js" | xargs claude review
```

### スクリプトとの統合

```bash
#!/bin/bash
# claude-review.sh

# すべての変更されたファイルをレビュー
for file in $(git diff --name-only); do
  echo "Reviewing $file..."
  claude review "$file" --output "reviews/${file}.md"
done
```

### CI/CD との統合

```yaml
# .github/workflows/claude-review.yml
name: Claude Code Review

on: [pull_request]

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Install Claude Code
        run: npm install -g @anthropic/claude-code
      - name: Run Claude Review
        env:
          CLAUDE_API_KEY: ${{ secrets.CLAUDE_API_KEY }}
        run: |
          claude review --directory ./src --output review.md
          cat review.md >> $GITHUB_STEP_SUMMARY
```

---

## 📊 ベストプラクティス

### 1. コンテキストの最適化
```bash
# 良い例：関連ファイルのみを含める
claude -c types.ts -c userService.ts "Add user authentication"

# 避けるべき例：不要なファイルを含める
claude -d . --recursive "Fix bug"  # プロジェクト全体は過剰
```

### 2. プロンプトの明確化
```bash
# 良い例：具体的な要求
claude "Convert this Express route to Next.js API route with TypeScript"

# 避けるべき例：曖昧な要求
claude "Make this better"
```

### 3. 出力の活用
```bash
# レビュー結果を保存
claude review src/ -o reviews/$(date +%Y%m%d).md

# JSON形式で他のツールと連携
claude review --json | jq '.issues[] | select(.severity == "high")'
```

### 4. テンプレートの活用
```bash
# プロジェクト固有のテンプレートを定義
echo "Generate React component with our coding standards" > .claude-templates/component.txt
claude code --template .claude-templates/component.txt "UserProfile"
```

---

## 🔒 セキュリティ考慮事項

### APIキーの管理
```bash
# 環境変数で管理
export CLAUDE_API_KEY="your-api-key"

# または .env ファイル
echo "CLAUDE_API_KEY=your-api-key" >> .env

# .gitignore に追加
echo ".env" >> .gitignore
echo ".claude.json" >> .gitignore
```

### 機密情報の除外
```bash
# 機密ファイルを除外
claude review -e "*.env,*.key,*.pem,*secret*"

# カスタム除外パターン
claude config set context.excludePatterns '["*.env", "secrets/", "*.key"]'
```

---

## 🛠️ トラブルシューティング

### よくある問題と解決方法

| 問題 | 原因 | 解決方法 |
|------|------|----------|
| "API key not found" | APIキーが設定されていない | `claude init` または環境変数設定 |
| "Context too large" | ファイルが大きすぎる | `--exclude` で不要なファイルを除外 |
| "Rate limit exceeded" | API制限に到達 | 少し待つか、キャッシュを有効化 |
| "Connection timeout" | ネットワークの問題 | `--timeout` で時間を延長 |
| "Invalid JSON response" | 出力形式の問題 | `--no-json` でプレーンテキスト出力 |

### デバッグモード
```bash
# 詳細なログ出力
claude --verbose review src/

# デバッグ情報を表示
CLAUDE_DEBUG=1 claude code "React component"

# ドライランで確認
claude --dry-run review
```

---

## 📚 リソース

### 公式ドキュメント
- [Claude Code Documentation](https://docs.anthropic.com/claude-code)
- [API Reference](https://docs.anthropic.com/claude-code/api)
- [Examples Repository](https://github.com/anthropic-ai/claude-code-examples)

### コミュニティ
- [Discord Server](https://discord.gg/anthropic)
- [GitHub Discussions](https://github.com/anthropic-ai/claude-code/discussions)
- [Stack Overflow Tag](https://stackoverflow.com/questions/tagged/claude-code)

### 更新情報
```bash
# 最新バージョンを確認
npm view @anthropic/claude-code version

# アップデート
npm update -g @anthropic/claude-code

# 変更ログを確認
claude changelog
```

---

このドキュメントは Claude Code の主要な機能とコマンドをカバーしています。プロジェクトの要件に応じて、設定をカスタマイズして活用してください。