module Kontena::Views
  class HttpIn
    include Hanami::View

    format :text
    template 'haproxy/http_in'
  end
end
