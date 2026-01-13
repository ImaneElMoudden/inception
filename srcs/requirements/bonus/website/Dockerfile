FROM alpine:3.22

RUN apk update && apk add --no-cache python3

COPY tools /var/www/html

WORKDIR /var/www/html

CMD ["python3", "-m", "http.server", "8000"]