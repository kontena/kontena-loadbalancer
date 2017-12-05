module Kontena::Views
  class HttpIn
    include Hanami::View

    format :text
    template 'haproxy/http_in'

    def ssl?
      ENV['SSL_CERTS'] || ENV.any? { |env, value| env.start_with? 'SSL_CERT_' }
    end
  end
end
