require 'concurrent/timer_task'
require 'etcd'

module Kontena::Actors
  class EtcdWatcher < Concurrent::Actor::RestartingContext
    include Kontena::Logging

    attr_reader :client, :path

    def initialize(host, path)
      info "initialized with etcd host=#{host} path=#{path}"
      @host = host
      @path = path
      @read_task = Concurrent::TimerTask.new(execution_interval: 1) {
        read_etcd
      }
    end

    def default_executor
      Concurrent.global_io_executor
    end

    # @param [Symbol,Array] msg
    def on_message(msg)
      command, _ = msg
      case command
      when :start
        start
      else
        pass
      end
    end

    def start
      @read_task.execute
    end

    def client
      @client ||= Etcd::Client.new(host: @host, port: 2379)
    end

    def read_etcd
      response = client.get(path, recursive: true)
      self.parent << [:generate_config, response.freeze]
    rescue Etcd::KeyNotFound
      client.set(path, dir: true)
      retry
    rescue => exc
      error "#{exc.class}: #{exc.message}"
    end
  end
end
