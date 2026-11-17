#!/bin/sh
# Railway wrapper for ClickHouse: refuses to start without a password,
# then hands over to the official entrypoint.
set -eu
export CLICKHOUSE_USER="${CLICKHOUSE_USER:-default}"
if [ -z "${CLICKHOUSE_PASSWORD:-}" ]; then
  echo "[railway] CLICKHOUSE_PASSWORD is empty; set it (the template generates one)" >&2
  exit 1
fi
exec /entrypoint.sh "$@"
