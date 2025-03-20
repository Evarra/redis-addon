#!/usr/bin/env bash
set -e

echo "Starting My Example Add-on"
echo "Greeting: ${GREETING}"

# Example of a long-running process:
while true; do
    echo "$(date): ${GREETING}"
    sleep 30
done

