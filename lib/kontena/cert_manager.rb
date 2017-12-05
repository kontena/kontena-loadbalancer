require 'fileutils'
require 'openssl'

module Kontena
  class CertManager
    include Kontena::Logging

    # Setup /etc/haproxy/certs from ENV
    def self.boot(env = ENV)
      cert_splitter = Kontena::CertSplitter.new(env)
      cert_manager = new(cert_splitter.to_h)

      if cert_manager.ssl_certs?
        cert_manager.setup
        cert_manager.write_certs
      end
    end

    attr_reader :ssl_certs

    # @param ssl_certs [Hash<String => String>]
    def initialize(ssl_certs)
      @ssl_certs = ssl_certs
    end

    # @return [Boolean]
    def ssl_certs?
      !ssl_certs.empty?
    end

    def setup
      FileUtils.mkdir_p('/etc/haproxy/certs')
    end

    # @param [Hash<String => String>] certs
    # @return [Integer] number of certs written
    def write_certs
      ssl_certs.each do |name, cert|
        write_cert(name, cert)
      end
    end

    # @param [String] name without .pem suffix
    # @param [String] cert
    def write_cert(name, cert)
      File.write("/etc/haproxy/certs/#{name}.pem", cert)
    end
  end
end
