# frozen_string_literal: true

module Mnemosyne
  class Instrumenter
    IDENT = :__mnemosyne_current_trace
    MUTEX = Mutex.new

    include ::Mnemosyne::Logging

    def initialize(config:, client:)
      @client = client
      @config = config

      ::Mnemosyne::Probes.activate!

      logger.debug(Mnemosyne) { 'Instrumenter started' }
    end

    def current_trace
      Thread.current[IDENT]
    end

    def current_trace=(trace)
      Thread.current[IDENT] = trace
    end

    def trace(name, **kwargs)
      if (trace = current_trace)
        return yield trace if block_given?

        return trace
      end

      trace = self.current_trace = Trace.new(self, name, **kwargs)

      return trace unless block_given?

      begin
        yield trace
      ensure
        self.current_trace = nil
        trace.submit
      end
    end

    def submit(trace)
      logger.debug(Mnemosyne) { "Submit trace #{trace.uuid}" }

      @client.call trace
    end

    def release(trace)
      return unless current_trace.equal?(trace)

      self.current_trace = nil
    end

    class << self
      attr_reader :instance

      def start!(config = nil)
        return @instance if @instance

        MUTEX.synchronize do
          return @instance if @instance

          client = Client.new(config)

          @instance = new(config: config, client: client)
        end
      rescue StandardError => e
        ::Mnemosyne::Logging.logger.warn(Mnemosyne) do
          "Unable to start instrumenter: #{e}"
        end

        raise
      end

      def with(instrumenter)
        old = instance
        @instance = instrumenter

        yield(instrumenter)
      ensure
        @instance = old
      end

      def trace(*args, **kwargs)
        return unless (instrumenter = instance)

        instrumenter.trace(*args, **kwargs)
      end

      def current_trace
        return unless (instrumenter = instance)

        instrumenter.current_trace
      end
    end
  end
end
