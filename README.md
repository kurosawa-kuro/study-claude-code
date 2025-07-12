# Claude Code Study Project

## 📋 概要

このプロジェクトは、Anthropic が提供する Claude Code の学習・検証環境です。WSL (Windows Subsystem for Linux) 環境での Claude Code のセットアップ、使用方法、ベストプラクティスをまとめています。

## 🚀 クイックスタート

### 前提条件
- Windows 10/11 with WSL2
- Ubuntu 20.04+ (WSL)
- 管理者権限

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

# プロジェクト別のコード生成
alias ccnext='claude "Next.js 14 with TypeScript"'     # Next.jsプロジェクト用
alias ccapi='claude "Express API with TypeScript"'      # API開発用
alias ccaws='claude "AWS CDK with TypeScript"'         # AWS開発用

# ファイル操作系
alias ccf='claude --file'                  # ファイルを指定して質問
alias ccd='claude --directory .'           # 現在のディレクトリを解析
alias ccr='claude --recursive'             # 再帰的にディレクトリ解析

# コンテキスト付きコマンド
alias ccfix='claude "Fix the error in this code:"'     # エラー修正依頼
alias cctest='claude "Write tests for this code:"'     # テスト作成依頼
alias ccopt='claude "Optimize this code:"'             # 最適化依頼
alias ccdoc='claude "Add JSDoc comments to:"'          # ドキュメント追加

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
# シンプルな質問
claude "What is the difference between let and const in JavaScript?"

# ファイルを読み込んで質問
claude --file app.js "Can you optimize this code?"

# 複数ファイルをコンテキストに
claude -c utils.js -c helpers.js "Refactor these utilities into a single module"

# ディレクトリ全体を解析
claude -d ./src --recursive "Find potential security issues"

# React コンポーネント生成
claude code "Create a React form component with validation"

# エラーログを送信して修正案を取得
cat error.log | claude fix
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