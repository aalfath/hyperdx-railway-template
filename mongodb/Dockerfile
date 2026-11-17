# MongoDB for HyperDX (users, teams, dashboards, alerts, saved searches).
# MongoDB 7.0, official image pinned by version and digest. 7.0 rather than 8.x:
# 8.x crash-loops on Linux 6.19+ hosts unless glibc rseq is turned off.
FROM mongo:7.0.48@sha256:884c055bff8b7144ca44830d01826facd3083b33c4dea44b94a1476c62de3c32

# Railway's private network is IPv6, so listen on :: as well as 0.0.0.0.
CMD ["mongod", "--ipv6", "--bind_ip_all", "--setParameter", "diagnosticDataCollectionEnabled=false"]
