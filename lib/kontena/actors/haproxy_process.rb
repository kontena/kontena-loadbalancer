
module Kontena::Actors
  class HaproxyProcess < Concurrent::Actor::Context
    include Kontena::Logging

    # @param [String] cmd
    def initialize(cmd)
      @cmd = cmd
    end

    def on_message(msg)
      command, _ = msg

      case command
      when :run
        run
      when :pid
        @pid
      else
        pass
      end
    end

    def run
      @pid = Process.spawn(@cmd.join(' '))
      info "HAProxy process #{@cmd} started (pid #{@pid})"
      @wait_pid = Concurrent::Future.execute { wait_pid(self.reference) }
      @pid
    end

    def wait_pid(reference)
      begin
        _, status = Process.wait2(@pid)
        info "process exited #{@pid}"
      ensure
        reference.tell([:terminate!, status])
      end
    end
  end
end
