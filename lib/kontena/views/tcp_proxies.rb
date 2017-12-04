module Kontena::Views
  class TcpProxies
    include Hanami::View

    format :text
    template 'haproxy/tcp_proxies'
  end
end
