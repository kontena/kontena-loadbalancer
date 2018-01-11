module Kontena::Actors
  class AcmeChallengeServer < Concurrent::Actor::RestartingContext
    include Kontena::Logging

    PORT = 54321

    class Servlet < WEBrick::HTTPServlet::AbstractServlet
      def initialize(server, acme_challenges)
        super(server)
        @acme_challenges = acme_challenges
      end

      def do_GET(req, res)
        parts = req.path.split('/')

        raise WEBrick::HTTPStatus::NotFound unless parts.length == 4

        challenge = parts[-1]

        if key_authorization = @acme_challenges.respond(challenge)
          res.status = 200
          res.content_type = 'text/plain'
          res.body = key_authorization
        else
          res.status = 404
          res.content_type = 'text/plain'
          res.body = "No key authorization for challenge: #{challenge}\n"
        end
      end
    end

    def initialize(acme_challenges, port: PORT, webrick_options: {})
      @acme_challenges = acme_challenges

      info "initialize"

      @server = WEBrick::HTTPServer.new(
        BindAddress: '127.0.0.1',
        Port: port,
        **webrick_options
      )
      @server.mount '/.well-known/acme-challenge', Servlet, @acme_challenges
    end

    # @param [Symbol,Array] msg
    def on_message(msg)
      case msg
      when :start
        start
      else
        pass
      end
    end

    def start
      # this blocks the actor executor thread in the accept() loop
      # the webrick servlets run as separate threads managed by webrick
      @server.start
    end

    def default_executor
      Concurrent.global_io_executor
    end
  end
end
