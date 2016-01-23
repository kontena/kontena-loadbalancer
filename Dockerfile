FROM ubuntu-debootstrap:trusty
MAINTAINER jari@kontena.io

ENV CONFD_VERSION=0.10.0 \
    STATS_PASSWORD=secret

RUN echo 'deb http://ppa.launchpad.net/vbernat/haproxy-1.5/ubuntu trusty main' >> /etc/apt/sources.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 505D97A41C61B9CD && \
    apt-get update

RUN apt-get install -yq --no-install-recommends haproxy ca-certificates curl net-tools && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    curl -L -o /bin/confd https://github.com/kelseyhightower/confd/releases/download/v${CONFD_VERSION}/confd-${CONFD_VERSION}-linux-amd64 && \
    chmod +x /bin/confd

EXPOSE 80 443

ADD entrypoint.sh /entrypoint.sh
ADD confd /etc/confd
ADD bin/* /usr/local/bin/
ADD errors/* /etc/haproxy/errors/

ENTRYPOINT ["/entrypoint.sh"]
