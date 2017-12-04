module Kontena::Actors
  class LbSupervisor < Concurrent::Actor::RestartingContext
    include Kontena::Logging

    def on_message(msg)
      command, *args = msg

      case command
      when :start
        start
      when :generate_config
        generate_config(args[0])
      when :write_config
        write_config(args[0])
      when :update_haproxy
        update_haproxy
      when :terminated
        raise "child actors should not terminate!"
      when :reset
        info "child #{envelope.sender_path} did reset"
        if envelope.sender == @spawner
          handle_spawner_reset
        end
      else
        pass
      end
    end

    # @return [String]
    def etcd_node
      ENV.fetch('ETCD_NODE') { '127.0.0.1' }
    end

    # @return [String]
    def etcd_path
      ENV.fetch('ETCD_PATH')
    end

    def start
      @syslog_server = SyslogServer.spawn!(name: 'syslog_server', supervise: true)
      @syslog_server << :start

      @config_generator = HaproxyConfigGenerator.spawn!(name: 'haproxy_config_generator', supervise: true)
      @config_writer = HaproxyConfigWriter.spawn!(name: 'haproxy_config_writer', supervise: true)
      @spawner = HaproxySpawner.spawn!(name: 'haproxy_spawner', supervise: true)

      @etcd_watcher = EtcdWatcher.spawn!(name: 'etcd_watcher', args: [etcd_node, etcd_path])
      @etcd_watcher << :start
    end

    def generate_config(value)
      @config_generator << [:update, value]
    end

    def write_config(value)
      @config_writer << [:update, value]
    end

    def update_haproxy
      @spawner << :update
    end

    def handle_spawner_reset
      if @config_writer.ask!(:config_written?)
        @spawner << :update
      else
        warn "cannot reset HAProxySpawner because config has not yet written"
      end
    end
  end
end
