#!/bin/bash
set -eo pipefail

# create dir to etcd
function etcd_mkdir() {
	curl -sL -X PUT http://$ETCD_NODE/v2/keys/kontena/haproxy/$KONTENA_SERVICE_NAME/$1 -d dir=true > /dev/null 2>&1
}

# set value to etcd
function etcd_set() {
	curl -sL -X PUT http://$ETCD_NODE/v2/keys/kontena/haproxy/$KONTENA_SERVICE_NAME/$1 -d $2 > /dev/null 2>&1
}

# remove key from etcd
function etcd_rm() {
	curl -sL -X DELETE http://$ETCD_NODE/v2/keys/kontena/haproxy/$KONTENA_SERVICE_NAME/$1 > /dev/null 2>&1
}

# bootstrap etcd paths and cleanup pid/config files
function bootstrap() {
	etcd_mkdir "services"
	etcd_mkdir "tcp-services"
	etcd_mkdir "certs"
	rm -f /var/run/haproxy.pid > /dev/null 2>&1
	rm -f /etc/haproxy/haproxy.cfg > /dev/null 2>&1
}

# split certificates
function split_certs() {
	echo "${SSL_CERTS}" > /tmp/certs.pem
  cd /tmp
  sed '/^$/d' certs.pem > certs_tmp.pem && csplit --elide-empty-files -s -f cert -b %02d_gen.pem certs_tmp.pem "/-----END .* PRIVATE KEY-----/+1"
  mkdir -p /etc/haproxy/certs > /dev/null 2>&1
  rm /etc/haproxy/certs/cert*_gen.pem > /dev/null 2>&1 || true
  mv cert*_gen.pem /etc/haproxy/certs/
	etcd_set "certs/bundle" "value=true"
  rm cert*_gen.pem > /dev/null 2>&1 || true
}

# tail debug log (bypass confd restrictions)
function tail_log() {
	touch /var/log/debug.log
	tail --pid $$ -F /var/log/debug.log &
}

function wait_confd() {
	# Loop until confd has updated the haproxy config
	until confd -onetime -node "$ETCD_NODE" -prefix="/kontena/haproxy/$KONTENA_SERVICE_NAME" "$@"; do
	  echo "[kontena-lb] waiting for confd to refresh haproxy.cfg"
	  sleep 5
	done
}

if [ -z "$ETCD_NODE"]; then
	IP=$(/sbin/ip route | awk '/default/ { print $3 }')
	ETCD_NODE=$IP:2379
fi

echo "[kontena-lb] booting $KONTENA_SERVICE_NAME. Using etcd: $ETCD_NODE"

bootstrap

if [ -n "$SSL_CERTS" ]; then
	echo -n "[kontena-lb] splitting bundled certificates..."
	split_certs
	echo "...done. Certificates updated into HAProxy."
else
  echo "[kontena-lb] No certificates found, disabling SSL support"
	etcd_rm "certs/bundle"
fi

tail_log
wait_confd

echo "[kontena-lb] Starting confd"
exec confd -node "$ETCD_NODE" -prefix="/kontena/haproxy/$KONTENA_SERVICE_NAME" "$@"
