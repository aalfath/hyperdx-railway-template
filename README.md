# HyperDX on Railway

A Railway template for [HyperDX](https://github.com/hyperdxio/hyperdx) (now also published as ClickStack): open-source observability for logs, traces, metrics, session replays and alerts, stored in ClickHouse and fed by OpenTelemetry.

**Version:** HyperDX 2.45.0 (`clickhouse/clickstack:2.45.0`, the same image as `hyperdx/hyperdx:2.45.0`), its OpenTelemetry collector 2.45.0, ClickHouse 26.10.3.7 (the version HyperDX 2.45.0's own `docker-compose.yml` uses) and MongoDB 7.0.48. Every image is pinned by version and digest in the `Dockerfile` of its folder.

## What it deploys

| Service | Folder | What it does | Volume |
|---|---|---|---|
| HyperDX | `hyperdx/` | Web UI, API and alert runner. Public domain on port 8080, health check `/api/health` | none (state lives in MongoDB and ClickHouse) |
| OTel Collector | `otel-collector/` | Receives OTLP (HTTP on the public domain, gRPC 4317 on the private network) and writes to ClickHouse. Runs the ClickHouse schema migrations on start and takes its pipeline from HyperDX over OpAMP. Health check `/` on port 13133 | none |
| ClickHouse | `clickhouse/` | Stores logs, traces, metrics and session replays (30-day TTL). Private only, password protected | `/var/lib/clickhouse` |
| MongoDB | `mongodb/` | Users, teams, dashboards, saved searches, alerts | `/data/db` |

## Variables

Nothing to fill in. The template generates the ClickHouse and MongoDB passwords, the session secret and the key that encrypts stored Slack and OAuth tokens. Everything else is a reference between the services (`${{ClickHouse.CLICKHOUSE_PASSWORD}}`, `${{HyperDX.RAILWAY_PRIVATE_DOMAIN}}` and so on).

| Service | Variable | Value |
|---|---|---|
| HyperDX | `FRONTEND_URL` | `https://${{RAILWAY_PUBLIC_DOMAIN}}`. Change it if you add a custom domain |
| HyperDX | `EXPRESS_SESSION_SECRET` | generated; keeps people logged in across restarts |
| HyperDX | `TOKEN_ENCRYPTION_KEY` | generated (64 hex characters); don't change it later, or stored Slack/OAuth tokens become unreadable |
| HyperDX | `MONGO_URI`, `CLICKHOUSE_URL`, `CLICKHOUSE_USER`, `CLICKHOUSE_PASSWORD` | references |
| OTel Collector | `CLICKHOUSE_ENDPOINT`, `CLICKHOUSE_USER`, `CLICKHOUSE_PASSWORD`, `OPAMP_SERVER_URL` | references |
| ClickHouse | `CLICKHOUSE_USER` / `CLICKHOUSE_PASSWORD` | `default` / generated |
| MongoDB | `MONGO_INITDB_ROOT_USERNAME` / `MONGO_INITDB_ROOT_PASSWORD` | `mongo` / generated |

## After deploying

1. Open the HyperDX domain and register. The first account creates the team; HyperDX then closes registration, so do this right away. The team gets a ready-made ClickHouse connection and Logs, Traces, Metrics and Sessions sources.
2. Copy the ingestion API key from **Team Settings**.
3. Point your OpenTelemetry SDK or collector at the collector's public domain:
   ```
   OTEL_EXPORTER_OTLP_ENDPOINT=https://YOUR-COLLECTOR-DOMAIN
   OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf
   OTEL_EXPORTER_OTLP_HEADERS=authorization=YOUR-INGESTION-API-KEY
   ```
   Requests without the key get `401`. Services in the same Railway project can use `http://${{OTel Collector.RAILWAY_PRIVATE_DOMAIN}}:4318` (or gRPC on 4317) instead.

Optional settings (SMTP for alerts, an AI assistant, OAuth, `WEBHOOK_HOSTNAME_ALLOWLIST`, retention via `HYPERDX_OTEL_EXPORTER_TABLES_TTL` on the collector) are described in the [ClickStack docs](https://clickhouse.com/docs/use-cases/observability/clickstack/overview).

## Updates

Each service builds from this repository's `main` branch. When a new HyperDX release comes out, the pinned digests are bumped here and the change is described in [CHANGELOG.md](CHANGELOG.md). Railway then shows everyone who deployed the template an "update available" notice, and you choose when to apply it. Read the changelog first: breaking changes are listed at the top of each entry.

## Local test

`compose.yaml` runs the same four images with test passwords: `HDX_PORT=8080 docker compose up -d --build`, then open http://localhost:8080.

## License

The wrapper files in this repository are MIT licensed. HyperDX is MIT licensed by its authors; ClickHouse is Apache-2.0; MongoDB Community Server is under the SSPL.
