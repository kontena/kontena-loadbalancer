require_relative 'common'

module Kontena::Views
  class HttpIn
    include Hanami::View
    include Kontena::Views::Common

    format :text
    template 'haproxy/http_in'

    def accept_proxy?
      ENV['KONTENA_LB_ACCEPT_PROXY']
    end

    def http2?
      ENV['KONTENA_LB_HTTP2'].to_s != 'false'
    end

    def health_uri
      if uri = ENV['KONTENA_LB_HEALTH_URI']
        _raw uri
      end
    end
  end
end
