#!/bin/sh
# Railway wrapper for the HyperDX app. It maps Railway's PORT to the UI port,
# builds the first-run ClickHouse connection from the template's variables,
# then hands over to the image's own start script (/etc/local/entry.sh).
set -eu

fail() { echo "[railway] $*" >&2; exit 1; }

: "${MONGO_URI:?MONGO_URI must point at the MongoDB service}"
: "${CLICKHOUSE_URL:?CLICKHOUSE_URL must point at the ClickHouse service (http://host:8123)}"
[ -n "${CLICKHOUSE_PASSWORD:-}" ] || fail "CLICKHOUSE_PASSWORD is empty"
[ -n "${EXPRESS_SESSION_SECRET:-}" ] || fail "EXPRESS_SESSION_SECRET is empty: without it every restart logs everyone out"

# Wait until MongoDB accepts connections. HyperDX's session store connects to
# MongoDB once at startup and never retries, so starting while MongoDB is still
# booting (for example when every service redeploys at once) leaves logins
# broken until the next restart.
node -e '
const net = require("net");
const u = new URL(process.env.MONGO_URI.replace(/^mongodb(\+srv)?:/, "http:"));
const host = u.hostname.replace(/^\[|\]$/g, ""), port = Number(u.port || 27017);
let n = 0;
(function tryOnce() {
  const s = net.connect({ host, port, timeout: 3000 });
  s.on("connect", () => { s.end(); console.log("[railway] MongoDB is up at " + host + ":" + port); process.exit(0); });
  const retry = () => { s.destroy(); if (++n >= 120) { console.error("[railway] MongoDB at " + host + ":" + port + " not reachable after 10 minutes"); process.exit(1); } console.log("[railway] waiting for MongoDB at " + host + ":" + port + " (" + n + ")..."); setTimeout(tryOnce, 5000); };
  s.on("timeout", retry); s.on("error", retry);
})();
'
# A TCP listener can open a moment before MongoDB serves queries.
sleep 3

export HYPERDX_APP_PORT="${PORT:-8080}"
export FRONTEND_URL="${FRONTEND_URL:-http://localhost:${HYPERDX_APP_PORT}}"

# Used only when the first user registers (the team's default connection and
# sources). Changing these later has no effect: edit them in Team Settings.
if [ -z "${DEFAULT_CONNECTIONS:-}" ]; then
  DEFAULT_CONNECTIONS="$(node -e 'process.stdout.write(JSON.stringify([{name:"Local ClickHouse",host:process.env.CLICKHOUSE_URL,username:process.env.CLICKHOUSE_USER||"default",password:process.env.CLICKHOUSE_PASSWORD}]))')"
  export DEFAULT_CONNECTIONS
fi
if [ -z "${DEFAULT_SOURCES:-}" ]; then
  DEFAULT_SOURCES="$(cat /etc/railway/default-sources.json)"
  export DEFAULT_SOURCES
fi

echo "[railway] HyperDX UI on port ${HYPERDX_APP_PORT}, API on ${HYPERDX_API_PORT}, OpAMP on ${HYPERDX_OPAMP_PORT}"
exec sh /etc/local/entry.sh
