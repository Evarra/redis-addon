#!/usr/bin/env bash
set -e

# Väline kataloog, kuhu Redis salvestab andmed ja konfiguratsioonifailid
PERSISTENT_DIR="/share/redis_persistent"
CONF_FILE="${PERSISTENT_DIR}/redis.conf"

mkdir -p "${PERSISTENT_DIR}"

# Kui redis.conf ei eksisteeri, loo see vaikimisi seadetega
if [ ! -f "${CONF_FILE}" ]; then
  echo "redis.conf ei eksisteeri, loon vaikimisi faili ${CONF_FILE}"
  cat <<EOL > "${CONF_FILE}"
bind 0.0.0.0
port 6379
appendonly yes
appendfilename "appendonly.aof"
dbfilename "dump.rdb"
dir ${PERSISTENT_DIR}
save 900 1
save 300 10
save 60 10000
loglevel notice
protected-mode no
EOL
fi

echo "Redis käivitamine conf-failiga ${CONF_FILE}"

exec redis-server "${CONF_FILE}"
