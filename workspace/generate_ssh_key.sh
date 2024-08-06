#!/bin/bash

set -e

# Цвет для логов
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Функция для логирования
log() {
    echo -e "${GREEN}$(date '+%Y-%m-%d %H:%M:%S') $1${NC}"
}

# Генерация SSH ключа
generate_ssh_key() {
    log "Генерация SSH ключа..."
    ssh-keygen -t ed25519 -C "$EMAIL" -f ~/.ssh/$KEY_NAME -N "" || { echo "Ошибка генерации SSH ключа"; exit 1; }
    log "SSH ключ сгенерирован."
}

# Добавление SSH ключа в SSH агент
add_ssh_key_to_agent() {
    log "Добавление SSH ключа в SSH агент..."
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/$KEY_NAME
    log "SSH ключ добавлен в SSH агент."
}

# Вывод публичного ключа для добавления в удаленный сервис
show_public_key() {
    log "Публичный SSH ключ для добавления в удаленный сервис:"
    cat ~/.ssh/$KEY_NAME.pub
}

# Запрос данных у пользователя
read -p "Введите ваш email: " EMAIL
read -p "Введите имя файла для ключа (например, id_ed25519): " KEY_NAME

# Основная логика
if [ -f ~/.ssh/$KEY_NAME ]; then
    log "SSH ключ уже существует. Пропуск генерации."
else
    generate_ssh_key
fi

add_ssh_key_to_agent
show_public_key

log "Генерация SSH ключа завершена. Добавьте публичный ключ в удаленный сервис."

