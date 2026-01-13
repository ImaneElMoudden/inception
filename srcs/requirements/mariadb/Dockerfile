FROM alpine:3.22

RUN apk update \
    && apk add mariadb mariadb-client

COPY script.sh /usr/local/bin/script.sh
RUN chmod +x /usr/local/bin/script.sh

ENTRYPOINT ["script.sh"]
