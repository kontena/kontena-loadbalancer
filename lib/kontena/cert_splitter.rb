require 'openssl'

module Kontena
  class CertSplitter
    include Kontena::Logging

    # @return [Hash<String => String>]
    def self.from_env(env = ENV)
      cert_splitter = new(env)
      cert_splitter.to_h
    end

    def initialize(env = ENV)
      @env = env
    end

    # @param [String] cert_bundle
    # @return [Array<String>]
    def split_certs(cert_bundle)
      certs = []
      buffer = ''
      cert_bundle.lines.each do |l|
        buffer << l
        if l.match(/-----END (.*)PRIVATE KEY-----/)
          certs << buffer.strip
          buffer = ''
        end
      end

      certs
    end

    # @return [Array<String>]
    def ssl_certs
      @env['SSL_CERTS'] ? split_certs(@env['SSL_CERTS']) : []
    end

    # @return [Hash<String => String>]
    def ssl_cert_glob
      @env.select{|env, value| env.start_with? 'SSL_CERT_' }
    end

    def each
      i = 1

      ssl_certs.each do |cert|
        if valid_cert? cert
          yield "cert#{i}_gen", cert
        end
        i += 1
      end

      ssl_cert_glob.each do |name, cert|
        if valid_cert? cert
          yield name, cert
        end
      end
    end

    # @return [Hash<String => String>]
    def to_h
      certs = {}

      each do |name, cert|
        certs[name] = cert
      end

      certs
    end

    # @param [String] cert
    # @return [Boolean]
    def valid_cert?(cert)
      certificate = OpenSSL::X509::Certificate.new(cert)
      info "valid certificate: #{certificate.subject.to_s}"

      true
    rescue
      warn "invalid certificate: #{cert[0..50]}"
      false
    end
  end
end
