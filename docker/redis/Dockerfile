FROM redis:8.2.7-alpine3.22@sha256:223b183cbc49f5ff48728e1fc52ccf101f05072decad2bd9867281a3c9bf75fd
USER root
RUN apk add --no-cache su-exec
COPY docker/redis/entrypoint.sh /usr/local/bin/arzzaq-redis-entrypoint
RUN chmod 0555 /usr/local/bin/arzzaq-redis-entrypoint
ENTRYPOINT ["/usr/local/bin/arzzaq-redis-entrypoint"]
CMD ["redis-server"]
USER 999:999
