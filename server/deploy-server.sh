#!/bin/bash

set -e

# Функция для логирования
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1"
}

# Функция для обработки ошибок
error_exit() {
    log "Ошибка: $1"
    exit 1
}

# Проверка наличия необходимых утилит
command -v git >/dev/null 2>&1 || error_exit "git не установлен."
command -v pm2 >/dev/null 2>&1 || error_exit "pm2 не установлен."
command -v bun >/dev/null 2>&1 || error_exit "bun не установлен."

# Переменные окружения
PROJECT_DIR=$(pwd)
PROJECT_NAME=$(basename "$PROJECT_DIR")
BACKUP_BASE_DIR="${PROJECT_DIR}/../backups/${PROJECT_NAME}"
DEPLOY_DATE=$(date '+%Y%m%d-%H%M%S')
BACKUP_DIR="${BACKUP_BASE_DIR}/deploy_${DEPLOY_DATE}"

# Создание директории для бэкапов
sudo mkdir -p "$BACKUP_DIR" || error_exit "Не удалось создать директорию для бэкапов."
sudo chown -R $(whoami):$(whoami) "$BACKUP_DIR" || error_exit "Не удалось изменить владельца директории для бэкапов."
log "Директория для бэкапов создана по адресу $BACKUP_DIR"

# Функция для бэкапа файлов
backup_file() {
    local file="$1"
    local backup_path="${BACKUP_DIR}$(dirname "$file" | sed "s#^$PROJECT_DIR##")"
    sudo mkdir -p "$backup_path"
    sudo chown -R $(whoami):$(whoami) "$backup_path"
    cp "$file" "$backup_path"
    log "Сделан бэкап $file в $backup_path"
}

# Бэкап файлов .sqlite
log "Бэкап файлов базы данных SQLite..."
find "$PROJECT_DIR" -type f -name "*.sqlite" | while read -r file; do
    backup_file "$file"
done

# Бэкап .env* файлов
log "Бэкап .env* файлов..."
find "$PROJECT_DIR" -type f -name ".env*" | while read -r file; do
    backup_file "$file"
done

# Ограничение количества бэкапов до 5
log "Проверка количества бэкапов..."
backup_count=$(ls -d ${BACKUP_BASE_DIR}/deploy_* | wc -l)
if [ "$backup_count" -gt 5 ]; then
    oldest_backup=$(ls -d ${BACKUP_BASE_DIR}/deploy_* | head -n 1)
    log "Удаление старого бэкапа: $oldest_backup"
    rm -rf "$oldest_backup"
fi

# Запрос ветки для деплоя
read -p "Введите имя ветки для деплоя (по умолчанию 'main'): " DEPLOY_BRANCH
DEPLOY_BRANCH=${DEPLOY_BRANCH:-main}

# Запрос необходимости переустановки зависимостей
read -p "Хотите переустановить зависимости? (y/n, по умолчанию 'n'): " REINSTALL_DEPENDENCIES
REINSTALL_DEPENDENCIES=${REINSTALL_DEPENDENCIES:-n}

# Запрос необходимости удаления старых данных перед переустановкой зависимостей
if [[ "$REINSTALL_DEPENDENCIES" == "y" || "$REINSTALL_DEPENDENCIES" == "yes" ]]; then
    read -p "Хотите удалить старые данные (node_modules и bun.lock) перед переустановкой зависимостей? (y/n, по умолчанию 'n'): " DELETE_OLD_DATA
    DELETE_OLD_DATA=${DELETE_OLD_DATA:-n}
else
    DELETE_OLD_DATA="n"
fi

# Остановка и удаление процессов pm2 с именем папки проекта
log "Остановка и удаление процессов pm2 с именем $PROJECT_NAME..."
pm2 stop "$PROJECT_NAME" || true
pm2 delete "$PROJECT_NAME" || true

# Переход в директорию проекта
cd "$PROJECT_DIR"

# Обновление кода из репозитория
log "Переключение на ветку $DEPLOY_BRANCH..."
git checkout "$DEPLOY_BRANCH" || error_exit "Не удалось переключиться на ветку $DEPLOY_BRANCH"

log "Получение последнего кода из ветки $DEPLOY_BRANCH..."
git pull origin "$DEPLOY_BRANCH" || error_exit "Не удалось получить последний код из ветки $DEPLOY_BRANCH"

# Обновление пакетов
if [[ "$DELETE_OLD_DATA" == "y" || "$DELETE_OLD_DATA" == "yes" ]]; then
    log "Удаление старых данных (node_modules и bun.lock)..."
    bun update:deps || error_exit "Не удалось переустановить зависимости"
elif [[ "$REINSTALL_DEPENDENCIES" == "y" || "$REINSTALL_DEPENDENCIES" == "yes" ]]; then
    log "Переустановка зависимостей..."
    bun install || error_exit "Не удалось переустановить зависимости"
else
    log "Пропуск переустановки зависимостей..."
fi

# Запуск процессов pm2 с именем папки проекта
log "Сборка UI и запуск процессов pm2..."
bun build-ui && NODE_ENV=production pm2 start --name "$PROJECT_NAME" bun -- run ./src/run-server/main.ts || error_exit "Не удалось запустить процессы pm2"

log "Деплой успешно завершен."

