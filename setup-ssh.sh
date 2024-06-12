#!/bin/bash

# Запрос имени пользователя (по умолчанию текущий пользователь)
read -p "Введите имя пользователя [$(whoami)]: " username
username=${username:-$(whoami)}

# Проверка, существует ли пользователь
if ! id -u "$username" >/dev/null 2>&1; then
  echo "Ошибка: Пользователь '$username' не существует."
  exit 1
fi

# Запрос имени файла ключа (по умолчанию id_rsa)
read -p "Введите имя файла ключа [id_rsa]: " key_filename
key_filename=${key_filename:-id_rsa}

# Запрос на установку ключей
read -p "Хотите установить оба ключа (приватный и публичный)? (y/n): " install_both_keys

if [ "$install_both_keys" == "y" ] || [ "$install_both_keys" == "Y" ]; then
  # Запрос приватного ключа
  echo "Введите содержимое приватного ключа (Ctrl+D для завершения ввода):"
  private_key=""
  while IFS= read -r line; do
    private_key="${private_key}${line}\n"
  done

  # Проверка, пустой ли приватный ключ
  if [ -z "$private_key" ]; then
    echo "Ошибка: Приватный ключ не может быть пустым."
    exit 1
  fi
fi

# Запрос публичного ключа
echo "Введите содержимое публичного ключа:"
read -r public_key

# Проверка, пустой ли публичный ключ
if [ -z "$public_key" ]; then
  echo "Ошибка: Публичный ключ не может быть пустым."
  exit 1
fi

# Создание .ssh директории для указанного пользователя
user_home=$(eval echo ~$username)
ssh_dir="$user_home/.ssh"
mkdir -p "$ssh_dir"
chmod 700 "$ssh_dir"
chown $username:$username "$ssh_dir"

if [ "$install_both_keys" == "y" ] || [ "$install_both_keys" == "Y" ]; then
  # Создание файлов приватного и публичного ключей
  private_key_file="$ssh_dir/$key_filename"
  public_key_file="$private_key_file.pub"

  echo -e "$private_key" > "$private_key_file"
  echo "$public_key" > "$public_key_file"

  # Установка правильных прав доступа
  chmod 600 "$private_key_file"
  chmod 644 "$public_key_file"
  chown $username:$username "$private_key_file"
  chown $username:$username "$public_key_file"

  # Регистрация ключа в SSH agent от имени указанного пользователя
  sudo -u $username bash -c "eval \$(ssh-agent -s) && ssh-add $private_key_file"

  # Запрос на создание файла config
  read -p "Хотите настроить файл SSH config? (y/n): " create_config

  if [ "$create_config" == "y" ] || [ "$create_config" == "Y" ]; then
    # Запрос типа сервера
    read -p "Это для GitHub? (y/n): " is_github

    if [ "$is_github" == "y" ] || [ "$is_github" == "Y" ]; then
      # Установка конфигурации для GitHub
      config_file="$ssh_dir/config"
      echo "Host github.com
          HostName github.com
          User git
          IdentityFile $private_key_file" > "$config_file"
    else
      # Запрос данных для удаленного сервера
      read -p "Введите имя сервера: " server_name
      read -p "Введите Host (например 192.168.0.1): " ssh_host
      read -p "Введите имя пользователя для SSH: " ssh_user

      # Установка конфигурации для удаленного сервера
      config_file="$ssh_dir/config"
      echo "Host $server_name
          HostName $ssh_host
          User $ssh_user
          IdentityFile $private_key_file" > "$config_file"
    fi

    chmod 600 "$config_file"
    chown $username:$username "$config_file"

    echo "SSH config файл настроен."
  fi
else
  # Создание только публичного ключа
  public_key_file="$ssh_dir/$key_filename.pub"
  echo "$public_key" > "$public_key_file"
  chmod 644 "$public_key_file"
  chown $username:$username "$public_key_file"
fi

# Добавление публичного ключа в authorized_keys
authorized_keys_file="$ssh_dir/authorized_keys"
touch "$authorized_keys_file"
chmod 600 "$authorized_keys_file"
chown $username:$username "$authorized_keys_file"
cat "$public_key_file" >> "$authorized_keys_file"

echo "SSH keys and configuration set up successfully for user $username."
