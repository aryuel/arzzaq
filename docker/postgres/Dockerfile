FROM postgres:17.10-alpine3.24@sha256:742f40ea20b9ff2ff31db5458d127452988a2164df9e17441e191f3b72252193
USER root
RUN set -eux; \
    rm /usr/local/bin/gosu; \
    apk upgrade --no-cache; \
    apk add --no-cache su-exec
COPY docker/postgres/entrypoint.sh /usr/local/bin/arzzaq-postgres-entrypoint
RUN chmod 0555 /usr/local/bin/arzzaq-postgres-entrypoint
ENTRYPOINT ["/usr/local/bin/arzzaq-postgres-entrypoint"]
CMD ["postgres"]
USER 70:70
