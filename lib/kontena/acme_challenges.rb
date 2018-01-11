module Kontena
  class AcmeChallenges
    include Kontena::Logging

    def self.env
      ENV
    end

    # @return [Boolean]
    def self.configured?
      env.any? { |env, value| env.start_with? 'ACME_CHALLENGE_' }
    end

    def self.load_env(env)
      challenges = {}

      env.each do |env, value|
        _, prefix, suffix = env.partition(/^ACME_CHALLENGE_/)

        if prefix
          challenges[suffix] = value
        end
      end

      challenges
    end

    # Setup from ENV
    def self.boot(env = ENV)
      manager = new(load_env(env))
    end

    attr_reader :challenges

    # @param challenges [Hash{String => String}] ACME challenge token => keyAuthorization
    def initialize(challenges)
      @challenges = challenges
    end

    # @return [Boolean]
    def challenges?
      !challenges.empty?
    end

    # @param challenge [String] ACME challenge token from /.well-known/acme-challenge/...
    # @return [String, nil] ACME challenge keyAuthorization
    def respond(challenge)
      @challenges[challenge]
    end
  end
end
