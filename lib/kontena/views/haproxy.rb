require 'erb'
require_relative 'http_in'
require_relative 'http_backends'
require_relative 'tcp_proxies'

module Kontena::Views
  class Haproxy
    include Hanami::View

    format :text
    template 'haproxy/main'

    def http_in
      _raw Kontena::Views::HttpIn.render(format: :text, services: services)
    end

    def http_backends
      _raw Kontena::Views::HttpBackends.render(format: :text, services: services)
    end

    def tcp_proxies
      _raw Kontena::Views::TcpProxies.render(format: :text, services: tcp_services)
    end
  end
end
