#!/bin/bash

set -e

# Цвет для логов
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Функция для логирования
log() {
    echo -e "${GREEN}$(date '+%Y-%m-%d %H:%M:%S') $1${NC}"
}

# Запрос у пользователя информации для генерации ключа
read -p "Введите ваш email для использования в качестве комментария в ключе SSH: " email
read -p "Введите имя файла для сохранения ключа (например, id_rsa_github): " key_name
read -p "Введите название хоста для добавления в конфигурацию (например, github.com): " host

# Путь к ключу
key_path="$HOME/.ssh/$key_name"

# Проверка существования файла ключа
if [ -f "$key_path" ]; then
    read -p "Файл $key_path уже существует. Перезаписать? (y/n): " overwrite
    if [ "$overwrite" != "y" ]; then
        log "Генерация ключа отменена."
        exit 1
    fi
fi

# Генерация SSH ключа
ssh-keygen -t rsa -b 4096 -C "$email" -f "$key_path" -N ""
log "SSH ключ сгенерирован и сохранен в $key_path"

# Добавление ключа в ssh-agent
eval "$(ssh-agent -s)"
ssh-add "$key_path"
log "SSH ключ добавлен в ssh-agent"

# Настройка конфигурации SSH
config_file="$HOME/.ssh/config"
host_config="
Host $host
    HostName $host
    User git
    IdentityFile $key_path
"
if grep -q "Host $host" "$config_file"; then
    log "Конфигурация для $host уже существует в $config_file"
else
    echo "$host_config" >> "$config_file"
    log "Конфигурация для $host добавлена в $config_file"
fi

# Отображение публичного ключа
log "Ваш публичный ключ (скопируйте его и добавьте в ваш сервис):"
cat "${key_path}.pub"

