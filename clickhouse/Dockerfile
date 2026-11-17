# ClickHouse for HyperDX. Same version HyperDX 2.45.0's docker-compose.yml pins.
# Official image, pinned by version and digest.
FROM clickhouse/clickhouse-server:26.10.3.7-alpine@sha256:1b09f476eb1109522cfc0e8e4ddf6a4305263e7cdd310f7bd1d3fd29dfcb8b33

COPY config.d/ /etc/clickhouse-server/config.d/
COPY --chmod=0755 railway-start.sh /usr/local/bin/railway-start.sh

# The stock entrypoint sets the password of CLICKHOUSE_USER from
# CLICKHOUSE_PASSWORD and owns the data directory (the Railway volume).
ENV CLICKHOUSE_DEFAULT_ACCESS_MANAGEMENT=1

# 8123 HTTP (HyperDX UI queries, health check), 9000 native (collector)
EXPOSE 8123 9000

ENTRYPOINT ["/usr/local/bin/railway-start.sh"]
