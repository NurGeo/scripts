#!/bin/bash

# Проверка прав суперпользователя
if [ "$(id -u)" -ne 0; then
  echo "Запустите скрипт с правами суперпользователя."
  exit 1
fi

# Установка bun
echo ""
echo "+++++ Установка bun..."
curl -fsSL https://bun.sh/install | bash

# Установка node
echo ""
echo "+++++ Установка node..."
curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
sudo apt-get install -y nodejs

# Проверка установки npm
echo ""
echo "+++++ Установка npm..."
if ! command -v npm &> /dev/null
then
    sudo apt-get install -y npm
fi

# Обновление npm до последней версии
echo "Обновление npm до последней версии..."
sudo npm install -g npm@latest

# Установка pm2
echo ""
echo "+++++ Установка pm2..."
sudo npm install -g pm2

# Установка последней стабильной версии neovim
echo ""
echo "+++++ Установка последней стабильной стабильной версии neovim..."
curl -LO https://github.com/neovim/neovim/releases/download/stable/nvim.appimage
chmod u+x nvim.appimage
mkdir -p ~/.local/bin
mv nvim.appimage ~/.local/bin/nvim
echo 'export PATH="~/.local/bin:$PATH"' >> ~/.bashrc

# Установка компиляторов языка C
echo ""
echo "+++++ Установка компиляторов языка C..."
sudo apt update
sudo apt install -y build-essential
sudo apt install -y clang

# Установка unzip
echo ""
echo "+++++ Установка unzip..."
sudo apt-get install -y unzip

# Установка tmux
echo ""
echo "+++++ Установка tmux..."
sudo apt-get install -y tmux

# Установка lazygit
echo ""
echo "+++++ Установка lazygit..."
sudo add-apt-repository ppa:lazygit-team/release
sudo apt-get update
sudo apt-get install -y lazygit

# Установка fuse
echo ""
echo "+++++ Установка fuse..."
sudo apt-get install -y fuse

# Установка xinput
echo ""
echo "+++++ Установка xinput..."
sudo apt-get install -y xinput

# Установка ripgrep
echo ""
echo "+++++ Установка ripgrep..."
sudo apt-get install -y ripgrep

# Установка nginx
echo ""
echo "+++++ Установка nginx..."
sudo apt-get install -y nginx

# Установка настроек рабочей пространства
echo ""
echo "+++++ Установка настроек рабочей пространства..."
cd ~
git init
git stash
git pull git@github.com:NurGeo/my-linux-configs.git master

# Настройка tmux
echo ""
echo "+++++ Настройка tmux..."
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Настройка nvim
echo ""
echo "+++++ Настройка nvim..."
git clone git@github.com:NurGeo/nvim-configs.git ~/.config/nvim

# Установка Packer для nvim
echo ""
echo "+++++ Установка Packer для nvim..."
git clone --depth 1 https://github.com/wbthomason/packer.nvim \
  ~/.local/share/nvim/site/pack/packer/start/packer.nvim

source ~/.bashrc

echo ""
echo "+++++ Установка и настройка завершены."

# Напоминание пользователю
echo ""
echo "Напоминание:"
echo "1. Возможно необходимо будет заново загрузить файл '~/.bashrc'."
echo "2. Проверьте репозиторий NurGeo/nvim-configs для дополнительных настроек и плагинов."
echo "3. Проверьте репозиторий NurGeo/my-linux-configs для дополнительных конфигураций и установок."
echo ""
echo "Для завершения настройки рабочего пространства выполните следующие шаги:"
echo "1. Откройте Neovim и выполните команду ':PackerSync':"
echo "2. Перезапустите Neovim, чтобы убедиться, что все плагины установлены правильно:"
