# HyperDX (ClickStack) app: UI, API and alert runner in one container.
# Official image, pinned by version and digest. Same image as hyperdx/hyperdx:2.45.0.
# Bump this line (and CHANGELOG.md) to ship an update to every deployer.
FROM clickhouse/clickstack:2.45.0@sha256:f31b39bc9b9bb39c10447bdc5eec5d4a1d6291e3dbec48f4098d95cbcafbf54f

ENV HYPERDX_API_PORT=8000 \
    HYPERDX_OPAMP_PORT=4320 \
    HYPERDX_LOG_LEVEL=info \
    NEXT_TELEMETRY_DISABLED=1

COPY --chown=node:node default-sources.json /etc/railway/default-sources.json
COPY --chmod=0755 railway-start.sh /usr/local/bin/railway-start.sh

ENTRYPOINT ["/bin/sh", "/usr/local/bin/railway-start.sh"]
