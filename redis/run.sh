#!/usr/bin/env bash
set -e

DATA_DIR=/addon_configs/612aff27_redis_persistent
CONF_FILE="${DATA_DIR}/redis.conf"

mkdir -p "${DATA_DIR}"

if [ ! -f "${CONF_FILE}" ]; then
  echo "redis.conf ei eksisteeri, loon vaikimisi faili"
  cat <<EOL > "${CONF_FILE}"
bind 0.0.0.0
port 6379
appendonly yes
appendfilename "appendonly.aof"
dir ${DATA_DIR}
save 900 1
save 300 10
save 60 10000
loglevel notice
protected-mode no
EOL
fi

echo "Redis start käivitamine conf-failiga ${CONF_FILE}"

exec redis-server "${CONF_FILE}"
