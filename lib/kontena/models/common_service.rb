module Kontena::Models
  module CommonService

    attr_accessor :name,
                  :upstreams,
                  :balance,
                  :custom_settings

    def initialize(name)
      @name = name
      @upstreams = []
      @balance = 'roundrobin'
      @custom_settings = []
    end

    def custom_settings?
      @custom_settings.size > 0
    end
  end
end
