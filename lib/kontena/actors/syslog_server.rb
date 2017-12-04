module Kontena::Actors
  class SyslogServer < Concurrent::Actor::RestartingContext
    include Kontena::Logging

    LINE_REGEX = /^<(\d+)>(.*)/

    def initialize
      info "initialized"
      @server = UDPSocket.new
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
      @server.bind('127.0.0.1', 514)
      info "started"
      loop do
        data, _ = @server.recvfrom(1024)
        handle_data(data)
      end
    rescue Errno::EACCES => exc
      error exc.message
    end

    # @param [String] data
    def handle_data(data)
      if line = data.match(LINE_REGEX)
        puts line[2] if line[2]
      end
    rescue => exc
      error exc.message
    end

    def default_executor
      Concurrent.global_io_executor
    end
  end
end
