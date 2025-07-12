~/.bashrc または ~/.zshrc


```
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

```
source ~/.bashrc
```