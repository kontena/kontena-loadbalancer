require_relative 'common'

module Kontena::Views
  class HttpIn
    include Hanami::View
    include Kontena::Views::Common

    format :text
    template 'haproxy/http_in'
  end
end
