module Kontena::Views
  module Common

    def ssl?
      ENV['SSL_CERTS'] || ENV.any? { |env, value| env.start_with? 'SSL_CERT_' }
    end

    def health_uri?
      ENV['KONTENA_LB_HEALTH_URI']
    end
  end
end
