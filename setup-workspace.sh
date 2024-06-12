а!/bin/bash

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
apt-get install -y nodejs

# Установка последней стабильной версии neovim
echo ""
echo "+++++ Установка последней стабильной стабильной версии neovim..."
curl -LO https://github.com/neovim/neovim/releases/download/stable/nvim.appimage
chmod u+x nvim.appimage
mv nvim.appimage /.local/bin/nvim
echo 'export PATH="~/.local/bin:$PATH"' >> ~/.bashrc

# Установка local-web-server
echo ""
echo "+++++ Установка local-web-server..."
npm install -g local-web-server

# Установка xinput
echo ""
echo "+++++ Установка xinput..."
apt-get install -y xinput

# Установка ripgrep
echo ""
echo "+++++ Установка ripgrep..."
apt-get install -y ripgrep

# Настройка tmux
echo ""
echo "+++++ Настройка tmux..."
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
cat <<EOT > ~/.tmux.conf
# Пример содержимого tmux.conf
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
run '~/.tmux/plugins/tpm/tpm'
EOT
~/.tmux/plugins/tpm/bin/install_plugins

# Настройка nvim
echo ""
echo "+++++ Настройка nvim..."
git clone git@github.com:NurGeo/nvim-configs.git ~/.config/nvim

# Установка Packer для nvim
echo ""
echo "+++++ Установка Packer для nvim..."
git clone --depth 1 https://github.com/wbthomason/packer.nvim \
  ~/.local/share/nvim/site/pack/packer/start/packer.nvim

echo ""
echo "+++++ Установка и настройка завершены."

# Напоминание пользователю
echo ""
echo "Напоминание:"
echo "1. Проверьте репозиторий NurGeo/nvim-configs для дополнительных настроек и плагинов."
echo "2. Проверьте репозиторий NurGeo/my-linux-configs для дополнительных конфигураций и установок."
echo ""
echo "Для завершения настройки рабочего пространства выполните следующие шаги:"
echo "1. Откройте Neovim и выполните команду ':PackerSync':"
echo "2. Перезапустите Neovim, чтобы убедиться, что все плагины установлены правильно:"
