FROM alpine:3.22

RUN apk update && apk add --no-cache redis

# allow connections
RUN sed -i "s|bind 127.0.0.1|#bind 127.0.0.1|g" /etc/redis.conf \
    # allow outside connections without a password
    && sed -i "s|protected-mode yes|protected-mode no|g" /etc/redis.conf \
    # cap memory available for use
    && sed -i "s|# maxmemory <bytes>|maxmemory 256mb|g" /etc/redis.conf \
    # remove old data when memory is full
    && sed -i "s|# maxmemory-policy noeviction|maxmemory-policy allkeys-lru|g" /etc/redis.conf

ENTRYPOINT ["redis-server", "/etc/redis.conf"]
