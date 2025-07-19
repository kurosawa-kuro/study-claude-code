# Claude Code Study Project

## 📋 概要

このプロジェクトは、Anthropic が提供する Claude Code の学習・検証環境です。WSL (Windows Subsystem for Linux) 環境での Claude Code のセットアップ、使用方法、ベストプラクティスをまとめています。

## 🚀 クイックスタート

### 前提条件
- Windows 10/11 with WSL2
- Ubuntu 20.04+ (WSL)
- 管理者権限

## 🛠️ 利用前提技術

このプロジェクトでは以下の技術スタックを前提としています：

### Node.js
- **バージョン**: 18.0.0以上推奨
- **用途**: サーバーサイドJavaScript実行環境
- **確認方法**: `node --version`
- **インストール**: NVMを使用して管理

```bash
# Node.jsのバージョン確認
node --version

# 最新版のインストール
nvm install node
nvm use node
```

### Nuxt.js
- **バージョン**: 3.x
- **用途**: Vue.jsベースのフルスタックフレームワーク
- **特徴**: SSR、SSG、SPA対応
- **インストール**: `npm install -g nuxi`

```bash
# Nuxtプロジェクトの作成
npx nuxi@latest init my-nuxt-app

# 開発サーバーの起動
cd my-nuxt-app
npm run dev

# ビルド
npm run build
```

### Express.js
- **バージョン**: 4.x
- **用途**: Node.js Webアプリケーションフレームワーク
- **特徴**: 軽量、柔軟、ミドルウェア対応
- **インストール**: `npm install express`

```bash
# Expressプロジェクトの初期化
npm init -y
npm install express

# 基本的なサーバー作成例
# app.js
const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.send('Hello World!');
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
```

### AWS CloudFormation
- **用途**: AWSリソースのインフラストラクチャ・アズ・コード
- **特徴**: JSON/YAMLテンプレート、自動デプロイ
- **前提**: AWS CLI、AWS認証情報の設定

```bash
# AWS CLIのインストール
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# AWS認証情報の設定
aws configure

# CloudFormationテンプレートのデプロイ
aws cloudformation create-stack \
  --stack-name my-stack \
  --template-body file://template.yaml \
  --capabilities CAPABILITY_IAM
```

### 技術スタックの組み合わせ例

```bash
# フルスタック開発環境のセットアップ
# 1. Nuxt.jsフロントエンド
npx nuxi@latest init frontend
cd frontend
npm install

# 2. Express.jsバックエンド
mkdir backend
cd backend
npm init -y
npm install express cors dotenv

# 3. CloudFormationでインフラ管理
mkdir infrastructure
cd infrastructure
# template.yaml を作成
```

### 1. システムパッケージの更新

```bash
sudo apt update && sudo apt upgrade -y
```

### 2. 開発ツールのインストール

```bash
sudo apt install build-essential curl git -y
```

### 3. Node.js環境の確認

```bash
node --version
npm --version
```

### 4. NVMのインストール

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
```

### 5. 環境の再読み込み

```bash
source ~/.bashrc
```

### 6. 最新のNode.jsをインストール

```bash
nvm install node
nvm use node
```

### 7. npmのグローバルディレクトリを設定（権限エラー回避）

```bash
mkdir -p ~/.npm-global
npm config set prefix ~/.npm-global
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```

### 8. Claude Codeのインストール

```bash
# 基本インストール
npm install -g @anthropic-ai/claude-code

# 詳細ログ付きインストール（トラブルシューティング用）
npm install -g @anthropic-ai/claude-code --verbose --progress
```

```
npm install -g claude-code
```

### 9. 動作確認

```bash
claude --version
```

### 10. Claude Codeの起動

```bash
claude
```

## 📁 プロジェクト構造

```
my-study/study-claude-code/
├── README.md              # このファイル
├── Makefile              # 開発環境管理用Makefile
├── docs/
│   ├── technique.md      # 技術ドキュメント
│   └── alias.md          # エイリアス設定
└── src/
    ├── check-version.sh  # バージョン確認スクリプト
    └── setup_wsl.sh      # WSLセットアップスクリプト
```

## 🛠️ Makefile コマンド

このプロジェクトには便利なMakefileが含まれています：

```bash
# ヘルプ表示
make help

# Claude Codeのバージョンを確認
make check-version

# WSL開発環境をセットアップ
make setup-wsl

# 完全な開発環境セットアップ
make dev-setup

# 現在の環境ステータスを表示
make status

# 一時ファイルをクリーンアップ
make clean
```

## ⚙️ 設定

### 初期設定

```bash
# 初回セットアップ
claude init
```

対話形式で以下を設定：
1. APIキーの入力
2. デフォルトモデルの選択
3. 出力形式の設定
4. プロジェクトのデフォルト設定

### エイリアス設定

`~/.bashrc` または `~/.zshrc` に以下を追加：

```bash
# Claude Code 基本コマンド
alias cc='claude'                          # 短縮形
alias cch='claude --help'                  # ヘルプ表示
alias ccv='claude --version'               # バージョン確認

# 技術スタック別のコード生成
alias ccnode='claude "Node.js with TypeScript"'        # Node.jsプロジェクト用
alias ccnuxt='claude "Nuxt.js 3 with TypeScript"'      # Nuxt.jsプロジェクト用
alias ccexpress='claude "Express.js with TypeScript"'  # Express.jsプロジェクト用
alias cccf='claude "AWS CloudFormation with YAML"'     # CloudFormation用

# フルスタック開発用
alias ccapi='claude "Express API with TypeScript and JWT authentication"'
alias ccfront='claude "Nuxt.js frontend with Tailwind CSS"'
alias ccinfra='claude "AWS CloudFormation template for web application"'

# ファイル操作系
alias ccf='claude --file'                  # ファイルを指定して質問
alias ccd='claude --directory .'           # 現在のディレクトリを解析
alias ccr='claude --recursive'             # 再帰的にディレクトリ解析

# コンテキスト付きコマンド
alias ccfix='claude "Fix the error in this code:"'     # エラー修正依頼
alias cctest='claude "Write tests for this code:"'     # テスト作成依頼
alias ccopt='claude "Optimize this code:"'             # 最適化依頼
alias ccdoc='claude "Add JSDoc comments to:"'          # ドキュメント追加

# 技術固有のコマンド
alias ccmiddleware='claude "Create Express middleware for"'
alias ccroute='claude "Create Express route handler for"'
alias ccpage='claude "Create Nuxt.js page component for"'
alias cccomponent='claude "Create Vue.js component for"'
alias cctemplate='claude "Create CloudFormation template for"'

# git連携
alias cccommit='claude "Write a git commit message for these changes"'
alias ccpr='claude "Write a PR description for these changes"'
alias ccreview='claude "Review this code for potential issues"'
```

設定後、環境を再読み込み：

```bash
source ~/.bashrc
```

## 💻 基本的な使用方法

### コマンド構文
```bash
claude [command] [options] [prompt]
```

### 主要コマンド

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

### 使用例

```bash
# 基本的な質問（日本語でも英語でもOK）
claude "JavaScriptのletとconstの違いを教えて"
claude "Vue.jsでコンポーネントを作る方法を教えて"

# ファイルを読み込んで質問
claude --file app.js "このコードを最適化して"
claude --file nuxt.config.ts "このNuxt設定を改善して"
claude --file server.js "このExpressサーバーにエラーハンドリングを追加して"

# 複数ファイルをコンテキストに含めて質問
claude -c utils.js -c helpers.js "これらのユーティリティを一つのモジュールにまとめて"
claude -c package.json -c tsconfig.json "このプロジェクトの設定を確認して改善点を教えて"
claude -c template.yaml -c parameters.json "このCloudFormationテンプレートを最適化して"

# ディレクトリ全体を解析
claude -d ./src --recursive "セキュリティの問題がないかチェックして"
claude -d ./pages "このNuxtページのパフォーマンスを改善して"
claude -d ./server "このExpress APIのエラーハンドリングを改善して"

# Node.js関連
claude code "Node.jsでユーザー認証のAPIを作って"
claude code "Express.jsでRESTful APIを作って"
claude code "Node.jsでファイルアップロード機能を作って"

# Nuxt.js関連
claude code "Nuxt.jsでブログの一覧ページを作って"
claude code "Nuxt.jsでユーザーログインフォームを作って"
claude code "Nuxt.jsでAPIとの通信機能を作って"

# Express.js関連
claude code "Express.jsでミドルウェアを作って"
claude code "Express.jsでデータベース接続機能を作って"
claude code "Express.jsでJWT認証機能を作って"

# CloudFormation関連
claude code "CloudFormationでEC2インスタンスのテンプレートを作って"
claude code "CloudFormationでRDSデータベースのテンプレートを作って"
claude code "CloudFormationでALBとAuto Scalingのテンプレートを作って"

# エラー修正
cat error.log | claude fix
npm run build 2>&1 | claude "このビルドエラーを修正して"
npx tsc --noEmit 2>&1 | claude "このTypeScriptエラーを修正して"

# テスト作成
claude test userService.js "このサービスのテストを書いて"
claude "このVue.jsコンポーネントのテストを作って"
claude "このExpress APIのテストを作って"

# ドキュメント生成
claude docs --format markdown "このAPIのドキュメントを作って"
claude "この関数にJSDocコメントを追加して"
claude "このCloudFormationテンプレートのドキュメントを作って"

# コードレビュー
claude review src/ "このコードの改善点を教えて"
claude review pages/ "このNuxtページの改善点を教えて"
claude review server/ "このExpress APIの改善点を教えて"
git diff | claude "この変更内容をレビューして"

# 技術固有の質問
claude "Nuxt.jsのSSRとSSGの違いを教えて"
claude "Express.jsでCORSを設定する方法を教えて"
claude "CloudFormationでVPCを作成する方法を教えて"
```

## 🔧 トラブルシューティング

### よくある問題

| 問題 | 原因 | 解決方法 |
|------|------|----------|
| "API key not found" | APIキーが設定されていない | `claude init` または環境変数設定 |
| "Context too large" | ファイルが大きすぎる | `--exclude` で不要なファイルを除外 |
| "Rate limit exceeded" | API制限に到達 | 少し待つか、キャッシュを有効化 |
| "Connection timeout" | ネットワークの問題 | `--timeout` で時間を延長 |

### デバッグモード

```bash
# 詳細なログ出力
claude --verbose review src/

# デバッグ情報を表示
CLAUDE_DEBUG=1 claude code "React component"

# ドライランで確認
claude --dry-run review
```

## 📚 参考資料

- [Claude Code Documentation](https://docs.anthropic.com/claude-code)
- [API Reference](https://docs.anthropic.com/claude-code/api)
- [Examples Repository](https://github.com/anthropic-ai/claude-code-examples)

## 🔒 セキュリティ

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
```

## 📝 ライセンス

このプロジェクトは学習目的で作成されています。

## 🤝 コントリビューション

改善提案やバグ報告は歓迎します。プルリクエストを送信する前に、既存のIssueを確認してください。
--------------
