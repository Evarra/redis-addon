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
dir ${PERSISTENT_DIR}  # Redis-i andmefailid salvestatakse siia
save 900 1
save 300 10
save 60 10000
loglevel notice
protected-mode no
EOL
fi

# Kui Home Assistant add-on konfiguratsioon sisaldab seadistusi, lisa need
if [ -n "$SUPERVISOR_TOKEN" ]; then
    HA_OPTIONS=$(curl -s -H "Authorization: Bearer $SUPERVISOR_TOKEN" http://supervisor/options)
    REDIS_PASSWORD=$(echo "$HA_OPTIONS" | jq -r '.requirepass // empty')
    MAX_MEMORY_POLICY=$(echo "$HA_OPTIONS" | jq -r '.maxmemory_policy // empty')

    if [ -n "$REDIS_PASSWORD" ]; then
        echo "requirepass ${REDIS_PASSWORD}" >> "${CONF_FILE}"
    fi

    if [ -n "$MAX_MEMORY_POLICY" ]; then
        echo "maxmemory-policy ${MAX_MEMORY_POLICY}" >> "${CONF_FILE}"
    fi
fi

echo "Redis käivitamine conf-failiga ${CONF_FILE}"

exec redis-server "${CONF_FILE}"
