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

SWAPFILE=/swap

if [ -f $SWAPFILE ]; then
    CURRENT_SIZE=$(sudo swapoff -v $SWAPFILE 2>/dev/null && sudo swapon --show | grep $SWAPFILE | awk '{print $3}')
    log "Текущий размер swap: ${CURRENT_SIZE}KB"
    read -p "Введите новый размер swap в MB (по умолчанию 4096): " NEW_SIZE
    NEW_SIZE=${NEW_SIZE:-4096}
else
    log "Файл swap не найден. Создание нового swap файла."
    read -p "Введите размер swap в MB (по умолчанию 4096): " NEW_SIZE
    NEW_SIZE=${NEW_SIZE:-4096}
    sudo fallocate -l "${NEW_SIZE}M" $SWAPFILE
    sudo chmod 600 $SWAPFILE
    sudo mkswap $SWAPFILE
    sudo swapon $SWAPFILE
    sudo cp /etc/fstab /etc/fstab.bak
    sudo sh -c "echo '$SWAPFILE none swap sw 0 0' >> /etc/fstab"
    log "Создан новый swap файл размером ${NEW_SIZE}MB и добавлен в /etc/fstab."
    exit 0
fi

# Если файл swap уже существует, изменяем его размер
log "Изменение размера swap..."
sudo swapoff $SWAPFILE
sudo dd if=/dev/zero of=$SWAPFILE bs=1M count=$NEW_SIZE
sudo mkswap $SWAPFILE
sudo swapon $SWAPFILE
log "Размер swap изменен на ${NEW_SIZE}MB."

