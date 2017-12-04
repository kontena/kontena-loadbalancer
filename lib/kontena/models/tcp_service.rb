require_relative 'common_service'

module Kontena::Models
  class TcpService
    include CommonService

    attr_accessor :external_port

    def initialize(name)
      super(name)
      @balance = 'leastconn'
      @external_port = nil
    end
  end
end
