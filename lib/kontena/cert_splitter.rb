require 'fileutils'
require 'openssl'

module Kontena
  class CertSplitter
    include Kontena::Logging

    def initialize
      FileUtils.mkdir_p('/etc/haproxy/certs')
    end

    # @param [String] cert_bundle
    def split_and_write(cert_bundle)
      certs = split_certs(cert_bundle)
      write_certs(certs)
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

    # @param [Array<String>] certs
    # @return [Integer] number of certs written
    def write_certs(certs)
      i = 1
      certs.each do |cert|
        if valid_cert?(cert)
          write_cert(cert, "cert#{i}_gen.pem")
          i += 1
        end
      end
      i
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

    # @param [String] cert
    # @param [String] name
    def write_cert(cert, name)
      File.write("/etc/haproxy/certs/#{name}", cert)
    end
  end
end
