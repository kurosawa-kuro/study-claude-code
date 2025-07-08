

# 
# パッケージ更新
sudo apt update && sudo apt upgrade -y

# 開発ツールをインストール  
sudo apt install build-essential curl git -y



# Windows B WSL環境で実行
# Node.js環境確認
node --version
npm --version


# NVMをインストール
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# ターミナルを再起動またはソースを再読み込み
source ~/.bashrc

# 最新のNode.jsをインストール
nvm install node
nvm use node

# npmのグローバルディレクトリを設定（権限エラー回避）
mkdir -p ~/.npm-global
npm config set prefix ~/.npm-global
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
source ~/.bashrc


# bash# Claude Codeをインストール（sudoは使用しない）
npm install -g @anthropic-ai/claude-code

npm install -g @anthropic-ai/claude-code --verbose --progress

# Claude Code の動作確認
claude --version


# Claude Codeを起動
claude


＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
#!/bin/bash

# =============================================================================
# WSL Development Environment Setup Script
# Purpose: 高速な試作開発・技術検証環境のセットアップ
# Target: WSL (Windows Subsystem for Linux)
# =============================================================================

set -e  # エラー時に処理を停止

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Configuration
NVM_VERSION="v0.39.0"
NPM_GLOBAL_DIR="$HOME/.npm-global"

# =============================================================================
# System Package Updates
# =============================================================================
setup_system_packages() {
    log_info "システムパッケージを更新中..."
    
    sudo apt update && sudo apt upgrade -y
    
    log_info "開発ツールをインストール中..."
    sudo apt install -y \
        build-essential \
        curl \
        git \
        wget \
        unzip \
        software-properties-common
    
    log_success "システムパッケージのセットアップ完了"
}

# =============================================================================
# Node.js Environment Setup
# =============================================================================
check_existing_node() {
    log_info "既存のNode.js環境を確認中..."
    
    if command -v node &> /dev/null; then
        log_warning "Node.js $(node --version) が既にインストールされています"
        log_warning "npm $(npm --version) が既にインストールされています"
        return 0
    else
        log_info "Node.jsが見つかりません。NVMをインストールします"
        return 1
    fi
}

install_nvm() {
    log_info "NVM ${NVM_VERSION} をインストール中..."
    
    # Download and install NVM
    curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash
    
    # Source NVM
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    
    log_success "NVMインストール完了"
}

install_nodejs() {
    log_info "最新のNode.jsをインストール中..."
    
    # Install latest LTS Node.js
    nvm install --lts
    nvm use --lts
    nvm alias default node
    
    log_success "Node.js $(node --version) インストール完了"
    log_success "npm $(npm --version) インストール完了"
}

configure_npm() {
    log_info "npmのグローバル設定を構成中..."
    
    # Create global directory
    mkdir -p "$NPM_GLOBAL_DIR"
    
    # Configure npm prefix
    npm config set prefix "$NPM_GLOBAL_DIR"
    
    # Add to PATH if not already present
    if ! echo "$PATH" | grep -q "$NPM_GLOBAL_DIR/bin"; then
        echo "export PATH=\"$NPM_GLOBAL_DIR/bin:\$PATH\"" >> ~/.bashrc
        export PATH="$NPM_GLOBAL_DIR/bin:$PATH"
    fi
    
    log_success "npm設定完了"
}

# =============================================================================
# Claude Code Installation
# =============================================================================
install_claude_code() {
    log_info "Claude Codeをインストール中..."
    
    # Clean up any existing installation issues
    if [ -d "$NPM_GLOBAL_DIR/lib/node_modules/@anthropic-ai" ]; then
        log_warning "既存のClaude Codeインストールをクリーンアップ中..."
        rm -rf "$NPM_GLOBAL_DIR/lib/node_modules/@anthropic-ai"
        npm cache clean --force
    fi
    
    # Install Claude Code
    npm install -g @anthropic-ai/claude-code
    
    log_success "Claude Codeインストール完了"
}

verify_claude_code() {
    log_info "Claude Codeの動作確認中..."
    
    if command -v claude &> /dev/null; then
        local version=$(claude --version 2>&1 || echo "バージョン取得失敗")
        log_success "Claude Code正常動作確認: $version"
        return 0
    else
        log_error "Claude Codeコマンドが見つかりません"
        return 1
    fi
}

# =============================================================================
# Development Tools Setup
# =============================================================================
setup_development_tools() {
    log_info "追加の開発ツールをセットアップ中..."
    
    # Install commonly used global packages for rapid prototyping
    local packages=(
        "typescript"
        "ts-node"
        "@types/node"
        "nodemon"
        "prettier"
        "eslint"
    )
    
    for package in "${packages[@]}"; do
        log_info "インストール中: $package"
        npm install -g "$package" &> /dev/null || log_warning "$package のインストールに失敗"
    done
    
    log_success "開発ツールセットアップ完了"
}

# =============================================================================
# Project Template Setup
# =============================================================================
create_project_template() {
    log_info "プロジェクトテンプレートディレクトリを作成中..."
    
    local template_dir="$HOME/dev/templates"
    mkdir -p "$template_dir"
    
    # Create Next.js API template structure
    mkdir -p "$template_dir/nextjs-api-template"/{src/pages/api,lib,types,tests}
    
    log_success "プロジェクトテンプレート作成完了: $template_dir"
}

# =============================================================================
# Main Execution
# =============================================================================
main() {
    log_info "WSL開発環境セットアップを開始します..."
    log_info "対象技術スタック: Node.js, Next.js, Zod, Swagger, Claude Code"
    
    # System setup
    setup_system_packages
    
    # Node.js setup
    if ! check_existing_node; then
        install_nvm
        source ~/.bashrc
        install_nodejs
    fi
    
    configure_npm
    
    # Claude Code setup
    install_claude_code
    
    if ! verify_claude_code; then
        log_error "Claude Codeの検証に失敗しました"
        log_info "手動確認を実行してください: source ~/.bashrc && claude --version"
    fi
    
    # Additional tools
    setup_development_tools
    create_project_template
    
    log_success "=== セットアップ完了 ==="
    log_info "以下のコマンドでClaude Codeを開始できます:"
    log_info "  claude chat"
    log_info "  claude ask \"質問内容\" [ファイルパス]"
    log_info ""
    log_info "新しいターミナルセッションを開始するか、以下を実行してください:"
    log_info "  source ~/.bashrc"
}

# Script execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
