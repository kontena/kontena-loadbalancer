module Kontena::Actors
  class HaproxyConfigGenerator < Concurrent::Actor::RestartingContext
    include Kontena::Logging

    KEY_SEPARATOR = '/'.freeze

    def initialize
      info "initialized"
    end

    # @param [Message] msg
    def on_message(msg)
      command, *args = msg
      case command
      when :update
        update(args[0])
      else
        pass
      end
    end

    # @param [Etcd::Node] node
    def update(node)
      root = node.key
      services = []
      tcp_services = []
      node.children.each do |c|
        if c.key == "#{root}/services"
          services = generate_services(c)
        elsif c.key == "#{root}/tcp-services"
          tcp_services = generate_tcp_services(c)
        end
      end

      config = Kontena::Views::Haproxy.render({
        format: :text, services: services, tcp_services: tcp_services
      }).each_line.reject{ |l| l.strip == ''.freeze }.join
      parent << [:write_config, config.freeze]
    end

    # @param [Etcd::Node] node
    # @return [Array<Kontena::Models::Service]
    def generate_services(node)
      services = []
      node.children.sort_by { |c| c.key }.each do |c|
        services << generate_service(c)
      end

      services
    end

    # @param [Etcd::Node] node
    # @return [Kontena::Models::Service]
    def generate_service(node)
      service = Kontena::Models::Service.new(node.key.split(KEY_SEPARATOR)[-1])
      node.children.each do |c|
        key = c.key.split(KEY_SEPARATOR)[-1].to_sym

        case key
        when :upstreams
          service.upstreams = c.children.sort_by{ |u| u.key }.map { |u|
            Kontena::Models::Upstream.new(u.key.split('/')[-1], u.value)
          }
        when :balance
          service.balance = c.value
        when :virtual_hosts
          service.virtual_hosts = c.value.split(',').compact
        when :virtual_path
          service.virtual_path = c.value unless c.value.empty?
        when :keep_virtual_path
          service.keep_virtual_path = c.value
        when :cookie
          service.cookie = c.value
        when :basic_auth_secrets
          service.basic_auth_secrets = c.value
        when :health_check_uri
          service.health_check_uri = c.value
        when :custom_settings
          service.custom_settings = c.value.split("\n")
        else
          debug "unknown key: #{key}"
        end
      end
      service.freeze

      service
    end

    # @param [Etcd::Node]
    # @param [Array<Kontena::Models::TcpService>]
    def generate_tcp_services(node)
      services = []
      node.children.sort_by { |c| c.key }.each do |c|
        service = generate_tcp_service(c)
        if service.upstreams.size > 0 && service.external_port
          services << service
        end
      end
      services.freeze

      services
    end

    # @param [Etcd::Node]
    # @param [Kontena::Models::TcpService]
    def generate_tcp_service(node)
      service = Kontena::Models::TcpService.new(node.key.split(KEY_SEPARATOR)[-1])
      node.children.each do |c|
        key = c.key.split(KEY_SEPARATOR)[-1].to_sym

        case key
        when :upstreams
          service.upstreams = c.children.sort_by{ |u| u.key }.map { |u|
            Kontena::Models::Upstream.new(u.key.split(KEY_SEPARATOR)[-1], u.value)
          }
        when :balance
          service.balance = c.value
        when :external_port
          service.external_port = c.value
        when :health_check_uri
          service.health_check_uri = c.value
        when :custom_settings
          service.custom_settings = c.value.split("\n")
        end
      end
      service.freeze

      service
    end
  end
end
