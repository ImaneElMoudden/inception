FROM alpine:3.22

RUN apk update \
    && apk add nginx \
    && addgroup -g 1000 -S wp_user && \
    adduser -u 1000 -D -S -G wp_user wp_user \
    && chown -R wp_user:wp_user /var/lib/nginx

# create a system user with no password login and assign it to the group

COPY nginx.conf /etc/nginx/nginx.conf

ENTRYPOINT ["nginx"]
