require 'fileutils'
require 'openssl'

module Kontena
  class CertSplitter
    include Kontena::Logging

    def setup
      FileUtils.mkdir_p('/etc/haproxy/certs')
    end

    # @param [String] cert_bundle
    def split_and_write(cert_bundle)
      certs = {}
      i = 1

      for cert in split_certs(cert_bundle)
        certs["cert#{i}_gen"] = cert
        i += 1
      end

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

    # @param [Hash<String => String>] certs
    # @return [Integer] number of certs written
    def write_certs(certs)
      certs.each do |name, cert|
        if valid_cert?(cert)
          write_cert(cert, name)
        end
      end
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
    # @param [String] name without .pem suffix
    def write_cert(cert, name)
      File.write("/etc/haproxy/certs/#{name}.pem", cert)
    end
  end
end
