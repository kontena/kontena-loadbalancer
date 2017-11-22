#!/bin/bash
set -eo pipefail

# create dir to etcd
function etcd_mkdir() {
  curl -sL -X PUT http://$ETCD_NODE/v2/keys/kontena/haproxy/$LB_NAME/$1 -d dir=true > /dev/null 2>&1
}

# set value to etcd
function etcd_set() {
  curl -sL -X PUT http://$ETCD_NODE/v2/keys/kontena/haproxy/$LB_NAME/$1 -d $2 > /dev/null 2>&1
}

# remove key from etcd
function etcd_rm() {
  curl -sL -X DELETE http://$ETCD_NODE/v2/keys/kontena/haproxy/$LB_NAME/$1 > /dev/null 2>&1
}

# bootstrap etcd paths and cleanup pid/config files
function bootstrap() {
  etcd_mkdir "services"
  etcd_mkdir "tcp-services"
  etcd_mkdir "certs"
  rm -f /var/run/haproxy.pid > /dev/null 2>&1
  rm -f /etc/haproxy/haproxy.cfg > /dev/null 2>&1
  touch /var/log/haproxy.log
  chown syslog /var/log/haproxy.log
  rsyslogd
}

# split certificates
function load_cert() {
  local name=$1
  local path=$2

  if openssl x509 -in $path -noout &> /dev/null ; then
    echo "[kontena-lb] Valid certificate at $path"
    mv $path /etc/haproxy/certs/$name.pem
  else
    echo "[kontena-lb] ERROR: Invalid certificate $name at $path, ignoring so it does not crash whole LB." >&2
  fi
}

function split_certs() {
  echo "${SSL_CERTS}" > /tmp/certs.pem
  cd /tmp
  sed '/^$/d' certs.pem > certs_tmp.pem && csplit --elide-empty-files -s -f cert -b %02d_gen.pem certs_tmp.pem "/-----END .*PRIVATE KEY-----/+1" {*}

  for file in cert*_gen.pem
  do
    rc=0
    openssl x509 -in $file -text -noout > /dev/null 2>&1 || rc=$?
    if [ $rc -eq 0 ]
    then
      echo "[kontena-lb] Valid certificate at $file"
    else
      echo "[kontena-lb] ERROR: Invalid certificate found at $file, removing so it does not crash whole LB." >&2
      rm $file > /dev/null 2>&1
    fi
  done

  rm /etc/haproxy/certs/cert*_gen.pem > /dev/null 2>&1 || true
  mv cert*_gen.pem /etc/haproxy/certs/
  rm cert*_gen.pem > /dev/null 2>&1 || true
}

HAVE_CERTS=

function load_certs() {
  mkdir -p /tmp/ssl_certs
  mkdir -p /etc/haproxy/certs

  if [ -n "${SSL_CERTS}" ]; then
    echo "[kontena-lb] splitting bundled certificates from SSL_CERTS..."
    split_certs
    HAVE_CERTS=true
  fi

  for certenv in "${!SSL_CERT_@}"; do
    echo "[kontena-lb] loading bundled certificate from $certenv..."

    cat > /tmp/ssl_certs/$certenv.pem <<<"${!certenv}"
    load_cert "$certenv" /tmp/ssl_certs/$certenv.pem
    HAVE_CERTS=true
  done

  rm -rf /tmp/ssl_certs
}

# tail debug log (bypass confd restrictions)
function tail_log() {
  tail --pid $$ -F /var/log/haproxy.log &
}

function wait_confd() {
  # Loop until confd has updated the haproxy config
  until confd -onetime -node "$ETCD_NODE" -prefix="/kontena/haproxy/$LB_NAME" "$@"; do
    echo "[kontena-lb] waiting for confd to refresh haproxy.cfg"
    sleep 5
  done
}

if [ -z "$ETCD_NODE"]; then
  IP=$(/sbin/ip route | awk '/default/ { print $3 }')
  ETCD_NODE=$IP:2379
fi

if [ -z $KONTENA_STACK_NAME ] || [ "$KONTENA_STACK_NAME" == "null" ]; then
  LB_NAME=$KONTENA_SERVICE_NAME
else
  LB_NAME="$KONTENA_STACK_NAME/$KONTENA_SERVICE_NAME"
fi

echo "[kontena-lb] booting $LB_NAME. Using etcd: $ETCD_NODE"

bootstrap
load_certs

if [ "$HAVE_CERTS" ]; then
  echo "[kontena-lb] certificates updated into HAProxy."
  etcd_set "certs/bundle" "value=true"
else
  echo "[kontena-lb] No certificates found, disabling SSL support"
  etcd_rm "certs/bundle"
fi

tail_log
wait_confd

echo "[kontena-lb] Starting confd with prefix $LB_NAME"
exec confd -node "$ETCD_NODE" -prefix="/kontena/haproxy/$LB_NAME" "$@"
