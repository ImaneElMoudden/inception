FROM alpine:3.22

RUN apk update && apk add --no-cache goaccess

RUN mkdir -p /var/log/nginx
RUN mkdir -p /var/www/html

COPY script.sh /usr/local/bin/script.sh
RUN chmod +x /usr/local/bin/script.sh

CMD ["script.sh"]
