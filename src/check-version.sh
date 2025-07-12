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

claude --version