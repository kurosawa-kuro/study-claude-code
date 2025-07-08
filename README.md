

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


# Claude Codeを起動
claude
