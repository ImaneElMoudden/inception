FROM alpine:3.22

RUN apk update && apk add --no-cache \
    php83 \
    php83-session \
    php83-mysqli \
    php83-xml \
    php83-pdo_mysql \
    php83-json \
    php83-gettext \
    php83-mbstring \
    wget

WORKDIR /var/www/html

RUN wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php -O index.php

CMD ["php83", "-S", "0.0.0.0:8080", "-t", "/var/www/html"]
