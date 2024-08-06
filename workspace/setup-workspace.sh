#!/bin/bash

GREEN='\033[0;32m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}$(date '+%Y-%m-%d %H:%M:%S') $1${NC}"
}

# Проверка прав суперпользователя
if [ "$(id -u)" -ne 0; then
  log "Запустите скрипт с правами суперпользователя."
  exit 1
fi

# Настройка Git
log "+++++ Настройка Git..."
git config --global user.email "anzpro@gmail.com"
git config --global user.name "NurGeo"

# Установка настроек рабочей пространства
log "+++++ Установка настроек рабочей пространства..."
cd ~
git init
git remote add origin git@github.com:NurGeo/my-linux-configs.git
git fetch origin
git reset --hard origin/master

# Установка путей для скриптов
log "+++++ Установка путей для скриптов..."
cd ~/scripts
git remote remove origin
git remote add origin git@github.com:NurGeo/scripts.git

# Переход в папку для скачивания пакетов
log "+++++ Переход в папку для скачивания пакетов..."
mkdir -p ~/Downloads
cd ~/Downloads

# Установка unzip
log "+++++ Установка unzip..."
sudo apt-get install -y unzip

# Установка bun
log "+++++ Установка bun..."
curl -fsSL https://bun.sh/install | bash

# Установка node версии 18 и выше
log "+++++ Установка node версии 18 и выше..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Проверка установки npm
log "+++++ Установка npm..."
if ! command -v npm &> /dev/null
then
    sudo apt-get install -y npm
fi

# Установка pm2
log "+++++ Установка pm2..."
sudo npm install -g pm2

# Установка последней стабильной версии neovim
log "+++++ Установка последней стабильной стабильной версии neovim..."
curl -LO https://github.com/neovim/neovim/releases/download/stable/nvim.appimage
chmod u+x nvim.appimage
mkdir -p ~/.local/bin
mv nvim.appimage ~/.local/bin/nvim
echo 'export PATH="~/.local/bin:$PATH"' >> ~/.bashrc

# Установка компиляторов языка C
log "+++++ Установка компиляторов языка C..."
sudo apt update
sudo apt install -y build-essential
sudo apt install -y clang

# Установка tmux
log "+++++ Установка tmux..."
sudo apt-get install -y tmux

# Установка lazygit
log "+++++ Установка lazygit..."
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin

# Установка fuse
log "+++++ Установка fuse..."
sudo apt-get install -y fuse

# Установка xinput
log "+++++ Установка xinput..."
sudo apt-get install -y xinput

# Установка ripgrep
log "+++++ Установка ripgrep..."
sudo apt-get install -y ripgrep

# Установка nginx
log "+++++ Установка nginx..."
sudo apt-get install -y nginx

# Настройка tmux
log "+++++ Настройка tmux..."
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Настройка nvim
log "+++++ Настройка nvim..."
git clone git@github.com:NurGeo/nvim-configs.git ~/.config/nvim

# Установка Packer для nvim
log "+++++ Установка Packer для nvim..."
git clone --depth 1 https://github.com/wbthomason/packer.nvim \
  ~/.local/share/nvim/site/pack/packer/start/packer.nvim

source ~/.bashrc

log "+++++ Установка и настройка завершены."

# Напоминание пользователю
log "Напоминание:"
log "1. Возможно необходимо будет заново загрузить файл '~/.bashrc'."
log "2. Проверьте репозиторий NurGeo/nvim-configs для дополнительных настроек и плагинов."
log "3. Проверьте репозиторий NurGeo/my-linux-configs для дополнительных конфигураций и установок."
log "Для завершения настройки рабочего пространства выполните следующие шаги:"
log "1. Откройте Neovim и выполните команду ':PackerSync':"
log "2. Перезапустите Neovim, чтобы убедиться, что все плагины установлены правильно:"

