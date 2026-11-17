#!/bin/sh
# Railway wrapper for the HyperDX collector: waits until ClickHouse accepts
# connections (the schema migration in the image's entrypoint gives up at once
# otherwise), then hands over to the image's own entrypoint.
set -eu
: "${CLICKHOUSE_ENDPOINT:?CLICKHOUSE_ENDPOINT must point at the ClickHouse service (tcp://host:9000)}"
: "${OPAMP_SERVER_URL:?OPAMP_SERVER_URL must point at the HyperDX app (http://host:4320)}"
[ -n "${CLICKHOUSE_PASSWORD:-}" ] || { echo "[railway] CLICKHOUSE_PASSWORD is empty" >&2; exit 1; }

# tcp://host:9000?x=y -> host and port (IPv6 literals in [] are handled too)
hp="${CLICKHOUSE_ENDPOINT#*://}"; hp="${hp%%\?*}"; hp="${hp%%/*}"
case "$hp" in
  \[*\]:*) host="${hp%%]:*}"; host="${host#[}"; port="${hp##*]:}" ;;
  *:*) host="${hp%:*}"; port="${hp##*:}" ;;
  *) host="$hp"; port=9000 ;;
esac

i=0
until nc -z -w 3 "$host" "$port" >/dev/null 2>&1; do
  i=$((i + 1))
  [ "$i" -lt 120 ] || { echo "[railway] ClickHouse at $host:$port not reachable after 10 minutes" >&2; exit 1; }
  echo "[railway] waiting for ClickHouse at $host:$port ($i)..."
  sleep 5
done
echo "[railway] ClickHouse is up; running schema migrations and starting the collector"
exec /entrypoint.sh /opampsupervisor
