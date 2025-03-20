#!/usr/bin/env bash
set -e

DATA_DIR=/data
mkdir -p "${DATA_DIR}"

echo "Starting Redis with persistence at ${DATA_DIR}"

exec redis-server --appendonly yes --dir "${DATA_DIR}" --appendfilename "appendonly.aof"
