# =============================================================================
# WSL Development Environment Makefile
# Purpose: 高速な試作開発・技術検証環境の管理
# Target: WSL (Windows Subsystem for Linux)
# =============================================================================

# Configuration
SHELL := /bin/bash
.SHELLFLAGS := -e -c
.SUFFIXES:

# Directories
SRC_DIR := src
SCRIPTS_DIR := $(SRC_DIR)

# Scripts
CHECK_VERSION_SCRIPT := $(SCRIPTS_DIR)/check-version.sh
SETUP_WSL_SCRIPT := $(SCRIPTS_DIR)/setup_wsl.sh

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m

# Default target
.DEFAULT_GOAL := help

# =============================================================================
# Main Targets
# =============================================================================

.PHONY: help
help: ## このMakefileの使用方法を表示
	@echo -e "$(BLUE)WSL Development Environment Makefile$(NC)"
	@echo -e "$(BLUE)=====================================$(NC)"
	@echo ""
	@echo -e "$(GREEN)Available targets:$(NC)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(YELLOW)%-15s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo -e "$(GREEN)Examples:$(NC)"
	@echo "  make check-version    # Claude Codeのバージョンを確認"
	@echo "  make setup-wsl        # WSL開発環境をセットアップ"
	@echo "  make clean            # 一時ファイルをクリーンアップ"

.PHONY: check-version
check-version: ## Claude Codeのバージョンを確認
	@echo -e "$(BLUE)[INFO] Claude Codeのバージョンを確認中...$(NC)"
	@chmod +x $(CHECK_VERSION_SCRIPT)
	@$(CHECK_VERSION_SCRIPT)

.PHONY: setup-wsl
setup-wsl: ## WSL開発環境をセットアップ
	@echo -e "$(BLUE)[INFO] WSL開発環境のセットアップを開始...$(NC)"
	@chmod +x $(SETUP_WSL_SCRIPT)
	@$(SETUP_WSL_SCRIPT)

# =============================================================================
# Utility Targets
# =============================================================================

.PHONY: check-scripts
check-scripts: ## スクリプトファイルの存在確認
	@echo -e "$(BLUE)[INFO] スクリプトファイルを確認中...$(NC)"
	@test -f $(CHECK_VERSION_SCRIPT) || (echo -e "$(RED)[ERROR] $(CHECK_VERSION_SCRIPT) が見つかりません$(NC)" && exit 1)
	@test -f $(SETUP_WSL_SCRIPT) || (echo -e "$(RED)[ERROR] $(SETUP_WSL_SCRIPT) が見つかりません$(NC)" && exit 1)
	@echo -e "$(GREEN)[SUCCESS] すべてのスクリプトファイルが存在します$(NC)"

.PHONY: validate
validate: check-scripts ## 環境の検証
	@echo -e "$(BLUE)[INFO] 環境を検証中...$(NC)"
	@command -v bash >/dev/null 2>&1 || (echo -e "$(RED)[ERROR] bash が見つかりません$(NC)" && exit 1)
	@command -v curl >/dev/null 2>&1 || (echo -e "$(YELLOW)[WARNING] curl が見つかりません$(NC)")
	@echo -e "$(GREEN)[SUCCESS] 環境検証完了$(NC)"

.PHONY: install-deps
install-deps: ## 基本的な依存関係をインストール
	@echo -e "$(BLUE)[INFO] 基本的な依存関係をインストール中...$(NC)"
	@sudo apt update
	@sudo apt install -y curl git wget unzip build-essential
	@echo -e "$(GREEN)[SUCCESS] 依存関係のインストール完了$(NC)"

.PHONY: clean
clean: ## 一時ファイルをクリーンアップ
	@echo -e "$(BLUE)[INFO] 一時ファイルをクリーンアップ中...$(NC)"
	@find . -name "*.tmp" -delete 2>/dev/null || true
	@find . -name "*.log" -delete 2>/dev/null || true
	@echo -e "$(GREEN)[SUCCESS] クリーンアップ完了$(NC)"

# =============================================================================
# Development Workflow Targets
# =============================================================================

.PHONY: dev-setup
dev-setup: validate install-deps setup-wsl ## 完全な開発環境セットアップ
	@echo -e "$(GREEN)[SUCCESS] 開発環境セットアップ完了$(NC)"

.PHONY: quick-check
quick-check: check-version ## クイックチェック（バージョン確認のみ）
	@echo -e "$(GREEN)[SUCCESS] クイックチェック完了$(NC)"

.PHONY: status
status: ## 現在の環境ステータスを表示
	@echo -e "$(BLUE)[INFO] 環境ステータスを確認中...$(NC)"
	@echo -e "$(YELLOW)Node.js:$(NC) $(shell command -v node >/dev/null 2>&1 && node --version || echo 'Not installed')"
	@echo -e "$(YELLOW)npm:$(NC) $(shell command -v npm >/dev/null 2>&1 && npm --version || echo 'Not installed')"
	@echo -e "$(YELLOW)Claude Code:$(NC) $(shell command -v claude >/dev/null 2>&1 && claude --version 2>/dev/null || echo 'Not installed')"
	@echo -e "$(YELLOW)Git:$(NC) $(shell command -v git >/dev/null 2>&1 && git --version || echo 'Not installed')"

# =============================================================================
# Advanced Targets
# =============================================================================

.PHONY: backup-scripts
backup-scripts: ## スクリプトファイルをバックアップ
	@echo -e "$(BLUE)[INFO] スクリプトファイルをバックアップ中...$(NC)"
	@mkdir -p backup/$(shell date +%Y%m%d)
	@cp $(CHECK_VERSION_SCRIPT) backup/$(shell date +%Y%m%d)/ 2>/dev/null || true
	@cp $(SETUP_WSL_SCRIPT) backup/$(shell date +%Y%m%d)/ 2>/dev/null || true
	@echo -e "$(GREEN)[SUCCESS] バックアップ完了: backup/$(shell date +%Y%m%d)/$(NC)"

.PHONY: restore-scripts
restore-scripts: ## 最新のバックアップからスクリプトを復元
	@echo -e "$(BLUE)[INFO] スクリプトファイルを復元中...$(NC)"
	@LATEST_BACKUP=$$(ls -t backup/ | head -1) && \
	if [ -n "$$LATEST_BACKUP" ]; then \
		cp backup/$$LATEST_BACKUP/* $(SCRIPTS_DIR)/ 2>/dev/null || true; \
		echo -e "$(GREEN)[SUCCESS] 復元完了: $$LATEST_BACKUP$(NC)"; \
	else \
		echo -e "$(RED)[ERROR] バックアップが見つかりません$(NC)"; \
	fi

# =============================================================================
# Documentation
# =============================================================================

.PHONY: docs
docs: ## ドキュメントを生成
	@echo -e "$(BLUE)[INFO] ドキュメントを生成中...$(NC)"
	@echo "# WSL Development Environment" > README.md
	@echo "" >> README.md
	@echo "## Quick Start" >> README.md
	@echo "" >> README.md
	@echo "### Setup Development Environment" >> README.md
	@echo "\`\`\`bash" >> README.md
	@echo "make dev-setup" >> README.md
	@echo "\`\`\`" >> README.md
	@echo "" >> README.md
	@echo "### Check Claude Code Version" >> README.md
	@echo "\`\`\`bash" >> README.md
	@echo "make check-version" >> README.md
	@echo "\`\`\`" >> README.md
	@echo "" >> README.md
	@echo "### View All Available Commands" >> README.md
	@echo "\`\`\`bash" >> README.md
	@echo "make help" >> README.md
	@echo "\`\`\`" >> README.md
	@echo -e "$(GREEN)[SUCCESS] README.md を生成しました$(NC)"

# =============================================================================
# Error Handling
# =============================================================================

.PHONY: check-permissions
check-permissions: ## スクリプトの実行権限を確認・修正
	@echo -e "$(BLUE)[INFO] スクリプトの実行権限を確認中...$(NC)"
	@chmod +x $(CHECK_VERSION_SCRIPT) 2>/dev/null || true
	@chmod +x $(SETUP_WSL_SCRIPT) 2>/dev/null || true
	@echo -e "$(GREEN)[SUCCESS] 実行権限の確認・修正完了$(NC)"

# =============================================================================
# Dependencies
# =============================================================================

# Ensure scripts are executable before running
check-version: check-permissions
setup-wsl: check-permissions
dev-setup: check-permissions