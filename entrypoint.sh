#!/bin/bash
set -eo pipefail


rm -f /var/run/haproxy.pid > /dev/null 2>&1
rm -f /etc/haproxy/haproxy.cfg > /dev/null 2>&1


if [ -z "$ETCD_NODE" ]; then
  IP=$(/sbin/ip route | awk '/default/ { print $3 }')
  ETCD_NODE=$IP
fi

if [ -z $KONTENA_STACK_NAME ] || [ "$KONTENA_STACK_NAME" == "null" ]; then
  LB_NAME=$KONTENA_SERVICE_NAME
else
  LB_NAME="$KONTENA_STACK_NAME/$KONTENA_SERVICE_NAME"
fi

export ETCD_NODE=$ETCD_NODE
export ETCD_PATH="/kontena/haproxy/$LB_NAME"
exec /app/bin/lb
