#!/bin/bash
set -eo pipefail

IP=$(/sbin/ip route | awk '/default/ { print $3 }')
ETCD_NODE=$IP:2379

#confd will start haproxy, since conf will be different than existing (which is null)

echo "[kontena-lb] booting $KONTENA_SERVICE_NAME. ETCD: $ETCD_NODE"

function config_fail()
{
	echo "Failed to start due to config error"
	exit -1
}

if [ -n "$SSL_CERTS" ]; then
  echo -e "${SSL_CERTS}" > /tmp/certs.pem

  echo "[kontena-lb] splitting bundled certificates..."
  cd /tmp
  sed '/^$/d' certs.pem > certs_tmp.pem && csplit --elide-empty-files -s -f cert -b %02d_gen.pem certs_tmp.pem "/-----END * PRIVATE KEY-----/+1"
  rm /etc/haproxy/certs/cert*_gen.pem
  mv cert*_gen.pem /etc/haproxy/certs/
  [ -f cert00_gen.pem ] && curl -sL -X PUT http://$ETCD_NODE/v2/keys/kontena/haproxy/$KONTENA_SERVICE_NAME/certs -d value=true
  rm cert*_gen.pem
  echo "...done. New certificates updated into HAProxy."
else
  curl -sL -X DELETE http://$ETCD_NODE/v2/keys/kontena/haproxy/$KONTENA_SERVICE_NAME/certs
fi


# Loop until confd has updated the haproxy config
n=0
until confd -onetime -node "$ETCD_NODE" -prefix="/kontena/haproxy/$KONTENA_SERVICE_NAME"; do
  if [ "$n" -eq "4" ];  then config_fail; fi
  echo "[kontena-lb] waiting for confd to refresh haproxy.cfg"
  n=$((n+1))
  sleep $n
done

echo "[kontena-lb] Initial HAProxy config created. Starting confd"

confd -node "$ETCD_NODE" -prefix="/kontena/haproxy/$KONTENA_SERVICE_NAME"
