require_relative 'common_service'

module Kontena::Models
  class Service
    include CommonService

    attr_accessor :virtual_hosts,
                  :virtual_paths,
                  :keep_virtual_path,
                  :health_check_uri,
                  :health_check_port,
                  :cookie,
                  :basic_auth_secrets

    def initialize(name)
      super
      @balance = 'roundrobin'
      @virtual_hosts = []
      @virtual_paths = []
      @keep_virtual_path = false
      @health_check_uri = nil
      @health_check_port = nil
      @cookie = nil
      @basic_auth_secrets = nil
    end

    def keep_virtual_path?
      @keep_virtual_path.to_s == 'true'
    end

    def virtual_hosts?
      @virtual_hosts.size > 0
    end

    def virtual_paths?
      @virtual_paths.size > 0
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
