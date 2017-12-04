require_relative 'haproxy_process'
require 'securerandom'

module Kontena::Actors
  class HaproxySpawner < Concurrent::Actor::RestartingContext
    include Kontena::Logging

    # @param [String] haproxy_bin
    # @param [String] config_file
    def initialize(haproxy_bin = '/usr/local/sbin/haproxy', config_file = '/etc/haproxy/haproxy.cfg')
      @current_pid = nil
      @haproxy_cmd = [haproxy_bin, '-f', config_file, '-db']
      @validate_cmd = [haproxy_bin, '-c -f', config_file]
    end

    def on_message(msg)
      command, _ = msg

      case command
      when :update
        update_haproxy
      when :terminated
        if children.size == 1
          raise "we don't have any child processes, all hope is gone"
        end
      else
        pass
      end
    end

    def update_haproxy
      if validate_config
        if children.size > 0
          reload_haproxy
        else
          start_haproxy
        end
      end
    end

    def start_haproxy
      spawn_process(@haproxy_cmd)
    end

    def validate_config
      info "validating config"
      system(@validate_cmd.join(' ')) == true
    end

    def reload_haproxy
      process = children.last
      info "child processes: #{children.map{ |c| c.ask!(:pid) }}"
      pid = process.ask!(:pid)
      reload_cmd = @haproxy_cmd + ['-sf', pid.to_s]
      spawn_process(reload_cmd)
    end

    def spawn_process(cmd)
      process_uuid = "haproxy-process-#{SecureRandom.uuid}"
      process = Kontena::Actors::HaproxyProcess.spawn!(name: process_uuid, args: [cmd])
      process << :run
      process
    end
  end
end
