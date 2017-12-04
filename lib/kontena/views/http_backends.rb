module Kontena::Views
  class HttpBackends
    include Hanami::View

    format :text
    template 'haproxy/http_backends'
  end
end
