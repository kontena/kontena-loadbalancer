FROM ubuntu-debootstrap:trusty
MAINTAINER Kontena, Inc. <info@kontena.io>

ENV CONFD_VERSION=0.11.0 \
    STATS_PASSWORD=secret \
    TINI_VERSION=v0.8.4

RUN echo 'deb http://ppa.launchpad.net/vbernat/haproxy-1.5/ubuntu trusty main' >> /etc/apt/sources.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 505D97A41C61B9CD && \
    apt-get update

RUN apt-get install -yq --no-install-recommends haproxy ca-certificates curl net-tools rsyslog && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    curl -sL -o /bin/confd https://github.com/kelseyhightower/confd/releases/download/v${CONFD_VERSION}/confd-${CONFD_VERSION}-linux-amd64 && \
    chmod +x /bin/confd && \
    curl -sL -o /bin/tini https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini && \
    chmod +x /bin/tini

EXPOSE 80 443
VOLUME ["/var/log"]
ADD entrypoint.sh /entrypoint.sh
ADD confd /etc/confd
ADD bin/* /usr/local/bin/
ADD errors/* /etc/haproxy/errors/
ADD rsyslog.conf /etc/rsyslog.d/49-haproxy.conf

ENTRYPOINT ["/bin/tini", "--", "/entrypoint.sh"]
