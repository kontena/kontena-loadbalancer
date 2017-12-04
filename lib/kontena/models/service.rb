require_relative 'common_service'

module Kontena::Models
  class Service
    include CommonService

    attr_accessor :virtual_hosts,
                  :virtual_path,
                  :keep_virtual_path,
                  :health_check_uri,
                  :cookie,
                  :basic_auth_secrets

    def initialize(name)
      super
      @balance = 'roundrobin'
      @virtual_hosts = []
      @virtual_path = nil
      @keep_virtual_path = false
      @health_check_uri = nil
      @cookie = nil
      @basic_auth_secrets = nil
    end

    def keep_virtual_path?
      @keep_virtual_path.to_s == 'true'
    end

    def virtual_hosts?
      @virtual_hosts.size > 0
    end

    def virtual_path?
      !@virtual_path.to_s.empty?
    end

    def cookie?
      !@cookie.nil?
    end

    def basic_auth?
      !@basic_auth_secrets.nil?
    end

    def health_check?
      !@health_check_uri.nil?
    end
  end
end
