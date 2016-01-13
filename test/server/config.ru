require "roda"
require "socket"
require "logger"

Logger.class_eval { alias :write :'<<' }

class App < Roda

  logger = Logger.new(STDOUT)
  use Rack::CommonLogger, logger

  route do |r|

    r.root do
      Socket.gethostname
    end

    r.on "path" do
      r.is do
        r.get do
          output = Socket.gethostname
          output << "\n"
          output << request.path
        end
      end
    end

    r.on "virtual_path" do
      r.is do
        r.get do
          output = Socket.gethostname
          output << "\n"
          output << request.path
        end
      end
    end
  end
end

run App.freeze.app
