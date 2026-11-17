# HyperDX (ClickStack) OpenTelemetry Collector. On start it applies the
# ClickHouse schema migrations, then runs under the OpAMP supervisor, which
# fetches its pipeline (and the ingestion API key check) from the HyperDX app.
# Official image, pinned by version and digest. Same image as hyperdx/hyperdx-otel-collector:2.45.0.
FROM clickhouse/clickstack-otel-collector:2.45.0@sha256:8ebe201c2990fba8afc54bd7c3c28290e967097fb3bca7062bad99a61cb53e8a

ENV HYPERDX_OTEL_EXPORTER_CLICKHOUSE_DATABASE=default \
    HYPERDX_LOG_LEVEL=info \
    OTEL_SUPERVISOR_LOGS=true

# 4317 OTLP gRPC, 4318 OTLP HTTP (public domain), 13133 health check
EXPOSE 4317 4318 13133

COPY --chmod=0755 railway-start.sh /usr/local/bin/railway-start.sh

ENTRYPOINT ["/bin/sh", "/usr/local/bin/railway-start.sh"]
