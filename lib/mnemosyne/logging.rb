module Mnemosyne
  module Logging
    def logger
      ::Mnemosyne::Logging.logger
    end

    class << self
      attr_writer :logger

      def logger
        @logger ||= ::Logger.new($stdout).tap do |logger|
          logger.level = ::Logger::INFO
        end
      end
    end
  end
end
