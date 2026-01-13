FROM alpine:3.22

RUN apk update && apk add --no-cache \
    php83 \
    php83-fpm \
    php83-mysqli \
    php83-json \
    php83-curl \
    php83-dom \
    php83-exif \
    php83-fileinfo \
    php83-mbstring \
    php83-openssl \
    php83-xml \
    php83-zip \
    php83-phar \
    php83-tokenizer \
    php83-ctype \
    wget \
    mariadb-client \
    php83-pecl-redis \
    redis

RUN addgroup -g 1000 -S wp_user && \
    adduser -u 1000 -D -S -G wp_user wp_user

# Configure PHP-FPM to listen to outside connections, change user
RUN sed -i 's|listen = 127.0.0.1:9000|listen = 0.0.0.0:9000|g' /etc/php83/php-fpm.d/www.conf && \
    sed -i 's/user = nobody/user = wp_user/g' /etc/php83/php-fpm.d/www.conf && \
    sed -i 's/group = nobody/group = wp_user/g' /etc/php83/php-fpm.d/www.conf

# Create symlink so php command works (needed for wp-cli)
RUN ln -sf /usr/bin/php83 /usr/bin/php

COPY script.sh /usr/local/bin/script.sh
RUN chmod +x /usr/local/bin/script.sh

WORKDIR /var/www/html

ENTRYPOINT ["script.sh"]