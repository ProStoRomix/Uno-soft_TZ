# Cassandra Cluster — Docker Compose

Три ноды Apache Cassandra в локальной сети с отдельными IP через драйвер `ipvlan`.

| Нода       | IP            |
|------------|---------------|
| cassandra1 | 192.168.1.200 |
| cassandra2 | 192.168.1.201 |
| cassandra3 | 192.168.1.202 |

**Машина А** (хост кластера): `192.168.1.197`  
**Машина Б** (клиент): `192.168.1.198`

---

## Требования

- Ubuntu 24.04 LTS на обеих машинах
- Docker Engine + docker-compose-plugin на Машине А
- `cqlsh` на Машине Б (`pip3 install cqlsh`)
- VirtualBox: Bridged Adapter + Promiscuous Mode → Allow All

---

## Запуск

```bash
# Проверить имя сетевого интерфейса и подставить в docker-compose.yml → parent
ip route | grep default

# Запустить кластер
docker compose up -d

# Проверить статус (ждать UN UN UN)
docker exec cassandra1 nodetool status
```

---

## Подключение с Машины Б

```bash
pip3 install cqlsh

cqlsh 192.168.1.200 9042
cqlsh 192.168.1.201 9042
cqlsh 192.168.1.202 9042
```

Проверить кластер внутри cqlsh:
```sql
SELECT peer, data_center, rack FROM system.peers;
```

---

## SSH доступ к cassandra1

```bash
# Установить SSH внутри контейнера (выполнить на Машине А)
docker exec -it cassandra1 bash -c "
    apt-get update -q &&
    apt-get install -y openssh-server &&
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config &&
    service ssh start &&
    echo 'root:cassandra' | chpasswd
"

# Подключиться
ssh root@192.168.1.200
# пароль: cassandra
```

---

## Результаты

### nodetool status (Машина А)

```
$ docker exec cassandra1 nodetool status
Datacenter: datacenter1
=======================
--  Address        Load        Tokens  Owns   Rack
UN  192.168.1.201  104.72 KiB  16      59.3%  rack1
UN  192.168.1.202  105 KiB     16      76.0%  rack1
UN  192.168.1.200  138.19 KiB  16      64.7%  rack1
```

### cqlsh подключение (Машина Б)

```
$ cqlsh 192.168.1.200 9042 -e "SELECT peer,data_center,rack FROM system.peers;"
 peer          | data_center | rack
---------------+-------------+-------
 192.168.1.202 | datacenter1 | rack1
 192.168.1.201 | datacenter1 | rack1

$ cqlsh 192.168.1.201 9042 -e "SELECT peer,data_center,rack FROM system.peers;"
 peer          | data_center | rack
---------------+-------------+-------
 192.168.1.202 | datacenter1 | rack1
 192.168.1.200 | datacenter1 | rack1

$ cqlsh 192.168.1.202 9042 -e "SELECT peer,data_center,rack FROM system.peers;"
 peer          | data_center | rack
---------------+-------------+-------
 192.168.1.200 | datacenter1 | rack1
 192.168.1.201 | datacenter1 | rack1
```

### SSH

```
$ ssh root@192.168.1.200
root@cassandra1:~#
```

---

> Скриншоты — в папке проекта
