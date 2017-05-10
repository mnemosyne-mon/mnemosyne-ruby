# frozen_string_literal: true

require 'thread'

module Mnemosyne
  class Instrumenter
    IDENT = :__mnemosyne_current_trace
    MUTEX = Mutex.new

    attr_reader :logger

    def initialize(config:, client:, logger:)
      @client = client
      @config = config
      @logger = logger

      ::Mnemosyne::Probes.activate!

      logger.info 'Mnemosyne instrumenter started.'
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
      blob = {
        hostname: @config.hostname,
        platform: @config.platform,
        application: @config.application
      }

      # TODO: nest
      blob.merge! trace.serialize

      logger.debug { "Submit trace #{trace.uuid}" }

      @client.send 'mnemosyne.trace', blob
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
          logger = config.logger

          @instance = new(config: config, client: client, logger: logger)
        end
      rescue => err
        message = "Unable to start instrumenter: #{err}"

        if config && config.respond_to?(:logger)
          config.logger.warn message
        else
          ::Kernel.warn message
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

      def trace(*args)
        return unless (instrumenter = instance)
        instrumenter.trace(*args)
      end

      def logger
        if (instrumenter = instance)
          instrumenter.logger
        else
          @logger ||= Logger.new($stdout)
        end
      end

      def current_trace
        return unless (instrumenter = instance)
        instrumenter.current_trace
      end
    end
  end
end
