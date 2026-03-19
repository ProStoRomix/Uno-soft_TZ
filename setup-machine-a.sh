#!/bin/bash
# setup-machine-a.sh — Подготовка Машины А (192.168.1.197)
# Запускать с правами sudo

set -e

sudo apt-get update -y


if ! command -v docker &> /dev/null; then
    sudo apt-get install -y ca-certificates curl gnupg lsb-release
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
        sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
      https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    sudo usermod -aG docker $USER
    echo "Docker установлен. ПЕРЕЗАПУСТИТЕ сессию, чтобы применить группу docker."
else
    echo "Docker уже установлен: $(docker --version)"
fi


IFACE=$(ip route | grep '^default' | awk '{print $5}' | head -1)
echo "Основной интерфейс: $IFACE"
echo ""
echo "ВАЖНО: Если имя интерфейса отличается от 'eth0',"
echo "откройте docker-compose.yml и замените 'eth0' на '$IFACE' в строке driver_opts.parent"

sudo apt-get install -y openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh
echo "SSH-сервер запущен."


if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -b 4096 -C "machine-a@cassandra-cluster" -f ~/.ssh/id_rsa -N ""
    echo "SSH-ключ создан: ~/.ssh/id_rsa"
else
    echo "SSH-ключ уже существует: ~/.ssh/id_rsa"
fi

echo "=== Готово! ==="

