module Kontena::Actors
  class HaproxyConfigWriter < Concurrent::Actor::RestartingContext
    include Kontena::Logging

    attr_accessor :config_file

    # @param [String] config_file
    def initialize(config_file = '/etc/haproxy/haproxy.cfg')
      self.config_file = config_file
      @old_config = ''
    end

    def on_message(msg)
      command, *args = msg
      case command
      when :update
        update_config(args[0])
      when :config_written?
        config_written?
      else
        pass
      end
    end

    def config_written?
      !@old_config.empty?
    end

    # @param [String] config
    def update_config(config)
      if @old_config != config
        write_config(config)
        @old_config = config
        parent << :update_haproxy
      end
    end

    # @param [String] config
    def write_config(config)
      File.write(config_file, config.to_s)
    end
  end
end
