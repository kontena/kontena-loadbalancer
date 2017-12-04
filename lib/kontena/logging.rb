module Kontena

  module Logging

  def self.initialize_logger(log_target = STDOUT)
    if ENV['DEBUG']
      @logger = Logger.new(log_target)
      @logger.level = Logger::DEBUG
    else
      @logger = Logger.new(log_target)
      @logger.level = ENV['LOG_LEVEL'] ? ENV['LOG_LEVEL'].to_i : Logger::INFO
    end
    @logger
  end

  def self.logger
    defined?(@logger) ? @logger : initialize_logger
  end

  def logger
    Logging.logger
  end

  # Send a debug message
  # @param [String] string
  def debug(string)
    logger.debug(self.class.name) { string }
  end

  # Send a info message
  # @param [String] string
  def info(string)
    logger.info(self.class.name) { string }
  end

  # Send a warning message
  # @param [String] string
  def warn(string)
    logger.warn(self.class.name) { string }
  end

  # Send an error message
  # @param [String] string
  def error(string)
    logger.error(self.class.name) { string }
  end

  end
end
