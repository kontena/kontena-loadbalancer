require_relative 'common'

module Kontena::Views
  class HttpIn
    include Hanami::View
    include Kontena::Views::Common

    format :text
    template 'haproxy/http_in'

    def acme_challenges?
      Kontena::AcmeChallenges.configured?
    end

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

    # sort services from most specific match to least specific match
    #
    # @return [Array<Kontena::Models::Service>]
    def sorted_services
      services.sort{|a, b|
        if a.virtual_hosts != b.virtual_hosts
          # reverse order, empty list goes last, wildcards go last
          b.virtual_hosts <=> a.virtual_hosts
        elsif a.virtual_paths != b.virtual_paths
          # reverse order, empty list goes last, longer prefixes go first
          b.virtual_paths <=> a.virtual_paths
        else
          # alphabetically on service name if duplicates
          a.name <=> b.name
        end
      }
    end
  end
end
