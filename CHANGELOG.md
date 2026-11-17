# Changelog

## 2.45.0 (2026-11-17)

First release of the template.

- The HyperDX service waits for MongoDB before it starts, so logins keep working when every service restarts at once.
- The collector waits for ClickHouse before it runs the schema migrations.

- HyperDX 2.45.0: `clickhouse/clickstack:2.45.0@sha256:f31b39bc9b9bb39c10447bdc5eec5d4a1d6291e3dbec48f4098d95cbcafbf54f`
- OpenTelemetry collector 2.45.0: `clickhouse/clickstack-otel-collector:2.45.0@sha256:8ebe201c2990fba8afc54bd7c3c28290e967097fb3bca7062bad99a61cb53e8a`
- ClickHouse 26.10.3.7: `clickhouse/clickhouse-server:26.10.3.7-alpine@sha256:1b09f476eb1109522cfc0e8e4ddf6a4305263e7cdd310f7bd1d3fd29dfcb8b33`
- MongoDB 7.0.48: `mongo:7.0.48@sha256:884c055bff8b7144ca44830d01826facd3083b33c4dea44b94a1476c62de3c32`
