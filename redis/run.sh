#!/usr/bin/env bash
set -e

# Väline konfiguratsiooni asukoht
EXTERNAL_CONF_DIR="/share/redis_persistent"
EXTERNAL_CONF_FILE="${EXTERNAL_CONF_DIR}/redis.conf"

# Sisemine andmete asukoht
DATA_DIR="/addon_configs/612aff27_redis_persistent"

mkdir -p "${DATA_DIR}"
mkdir -p "${EXTERNAL_CONF_DIR}"

# Kontrolli, kas väline konfiguratsioonifail eksisteerib, kui ei, loo vaikimisi
if [ ! -f "${EXTERNAL_CONF_FILE}" ]; then
  echo "redis.conf ei eksisteeri, loon vaikimisi faili ${EXTERNAL_CONF_FILE}"
  cat <<EOL > "${EXTERNAL_CONF_FILE}"
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

# Lisa võimalus lugeda Home Assistant add-on valikuid
if [ -n "$SUPERVISOR_TOKEN" ]; then
    HA_OPTIONS=$(curl -s -H "Authorization: Bearer $SUPERVISOR_TOKEN" http://supervisor/options)
    REDIS_PASSWORD=$(echo "$HA_OPTIONS" | jq -r '.requirepass // empty')
    MAX_MEMORY_POLICY=$(echo "$HA_OPTIONS" | jq -r '.maxmemory_policy // empty')

    if [ -n "$REDIS_PASSWORD" ]; then
        echo "requirepass ${REDIS_PASSWORD}" >> "${EXTERNAL_CONF_FILE}"
    fi

    if [ -n "$MAX_MEMORY_POLICY" ]; then
        echo "maxmemory-policy ${MAX_MEMORY_POLICY}" >> "${EXTERNAL_CONF_FILE}"
    fi
fi

echo "Redis start käivitamine conf-failiga ${EXTERNAL_CONF_FILE}"

exec redis-server "${EXTERNAL_CONF_FILE}"

