#!/bin/sh

exec goaccess /var/log/nginx/access.log \
    --log-format=COMBINED \
    -o /var/www/html/monitor.html \
    --real-time-html \
    --addr=0.0.0.0 \
    --port=7890 \
    --ws-url=wss://${domain_name}:700/ws
