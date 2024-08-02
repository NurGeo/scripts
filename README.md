# Настройка Рабочего Пространства и SSH

Этот репозиторий содержит скрипты, которые автоматизируют настройку рабочего пространства для разработки и настройку SSH ключей для вашего пользователя.

## Содержание файлов:

- workspace/
    - [setup-ssh.sh](./workspace/setup-ssh.sh): автоматизация установки ssh ключей. [Шаги](#установка-ключей-ssh)
    - [setup-workspace.sh](./workspace/setup-workspace.sh): автоматизация настройки рабочей среды. [Шаги](#автоматическая-настройка-рабочего-пространства-после-переустановки-linux)
- server/
    - [server-init-config](./server/server-init-config): содержит конфигурацию развертывания сервера. Устанавливает некоторые программы, добавляет и настраивает пользователя admin. При переустановке сервера, необходимо скопипастить в соответсвующее поле.
    - [deploy-server](./server/deploy-server.sh): перезапускает сервер. [Шаги](#деплой-сервера)

## Быстрый старт
Склонируйте репозиторий:

```sh
git clone https://github.com/nurgeo/scripts.git
cd scripts
```

## Скрипты сервера (server)
### Деплой сервера
1. Чтобы выполнить деплой нужно предварительно дать права на выполнение скрипта:
```sh
chmod +x server/deploy_server.sh
```

2. Переходим в папку с проектом и запускаем скрипт:
```sh
cd /srv/<project-name>/
~/scripts/server/deploy-server.sh
```

Шаги скрипта:
1. Бэкапит файлы `.env*, *.sqlite` в папку `../backups/<project-name>/deploy_<date-time>/`;
1. Удаляет старые бэкапы с `../backups/<project-name>/deploy_<date-time>/` если бэкапов больше 5;
1. Запросить ветку git с которого нужно запустить сервис, переходит на эту ветку, обновляется;
1. Запросить нужно ли переустановить зависимости (bun install);
1. Если в предыдущем да, то запрашивает нужно ли удалить текущие зависимости (node_modules, bun.lock): `update:deps`;
1. Остановить текущий сервис в pm2 (имя сервиса === имя текущей папки проекта);
1. Выполняет действия согласно ответов по установке зависимостей;
1. Запускает сервис через pm2 дав имя сервису согласно имени проекта (имя папки).

## Скрипты рабочего пространства (workspace)
### Установка ключей ssh
Автоматизация настройки SSH ключей для пользователя. Предполагается, что у вас есть уже сгенерированные ключи, которые вы хотите "положить" (а не сгенерировать новый) в папку .ssh/:

```sh
chmod +x setup-ssh.sh
./setup-ssh.sh
ssh -T git@github.com
```

Шаги скрипта:
- Прием имени пользователя (для кого устанавливаются ключи);
- Имя файла (сформированных ключей);
- Устанавливаем ли полный пакет (приватные или публичные) или только приватные ключи;
- Прием контента ключей;
  - Создание файлов и настройка прав доступа;
- Хотим ли генерировать config файл?. Обязательно если мы указываем нестандартное имя для файла;
  - Это конфиг файл для github?;
      - если да, то автоматическая настройка;
      - если нет, то запрос данных config-а;

### Автоматическая настройка рабочего пространства после переустановки linux
Этот скрипт автоматизирует настройку рабочего пространства для разработки. Устанавливает необходимые инструменты.
:

```sh
chmod +x setup-workspace.sh
./setup-workspace.sh
source ~/.bashrc
```
Шаги скрипта:
- Установка bun, node, npm, pm2, neovim, clang, tmux, lazygit, fuse, xinput, nginx;
- Настройка tmux и neovim;

Шаги после:
- Далее, запустите nvim и установите пакеты `:PackerSync`;
