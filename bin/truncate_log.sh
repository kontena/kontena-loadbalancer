#!/bin/sh

echo "[kontena-lb] Truncating log HAProxy log" >> /var/log/haproxy.log
cat /dev/null > /var/log/haproxy.log