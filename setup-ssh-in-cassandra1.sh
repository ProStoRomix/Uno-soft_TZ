#!/bin/bash

set -e
CONTAINER="cassandra1"


docker exec -it $CONTAINER bash -c "
    apt-get update -y -q && \
    apt-get install -y -q openssh-server && \
    mkdir -p /root/.ssh && \
    chmod 700 /root/.ssh && \
    echo '' >> /etc/ssh/sshd_config && \
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && \
    echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config && \
    service ssh start && \
    echo 'root:cassandra' | chpasswd && \
    echo 'SSH запущен, пароль root: cassandra'
"

# Копируем публичный ключ Машины А в контейнер
PUB_KEY=$(cat ~/.ssh/id_rsa.pub)
docker exec $CONTAINER bash -c "
    echo '$PUB_KEY' >> /root/.ssh/authorized_keys && \
    chmod 600 /root/.ssh/authorized_keys
"

