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

curl -sL -X PUT http://$ETCD_NODE/v2/keys/kontena/haproxy/$KONTENA_SERVICE_NAME/certs -d dir=true > /dev/null 2>&1
rm -f /var/run/haproxy.pid > /dev/null 2>&1
rm -f /etc/haproxy/haproxy.cfg > /dev/null 2>&1

if [ -n "$SSL_CERTS" ]; then
  echo "${SSL_CERTS}" > /tmp/certs.pem

  echo -n "[kontena-lb] splitting bundled certificates..."
  cd /tmp
  sed '/^$/d' certs.pem > certs_tmp.pem && csplit --elide-empty-files -s -f cert -b %02d_gen.pem certs_tmp.pem "/-----END .* PRIVATE KEY-----/+1"
  mkdir -p /etc/haproxy/certs > /dev/null 2>&1
  rm /etc/haproxy/certs/cert*_gen.pem > /dev/null 2>&1 || true
  mv cert*_gen.pem /etc/haproxy/certs/
  curl -sL -X PUT http://$ETCD_NODE/v2/keys/kontena/haproxy/$KONTENA_SERVICE_NAME/certs/bundle -d value=true > /dev/null 2>&1
  rm cert*_gen.pem > /dev/null 2>&1 || true
  echo "...done. Certificates updated into HAProxy."
else
  echo "[kontena-lb] No certificates found, disabling SSL support"
	curl -sL -X DELETE http://$ETCD_NODE/v2/keys/kontena/haproxy/$KONTENA_SERVICE_NAME/certs/bundle > /dev/null 2>&1
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
