module Kontena::Views
  class HttpBackends
    include Hanami::View

    def acme_challenges?
      Kontena::AcmeChallenges.configured?
    end

    format :text
    template 'haproxy/http_backends'
  end
end
