# frozen_string_literal: true
require 'bunny'

module Mnemosyne
  class Client
    attr_reader :connection

    def initialize(config)
      @config = config
    end

    def connection
      @connection ||= begin
        @config.logger.info "[Mnemosyne] Connect to #{@config.server}..."

        connection = ::Bunny.new @config.amqp,
          logger: @config.logger,
          threaded: false

        connection.start
        connection
      end
    end

    def channel
      @channel ||= connection.create_channel
    end

    def exchange
      @exchange ||= channel.topic @config.exchange, durable: true
    end

    def call(trace)
      message = {
        hostname: @config.hostname,
        platform: @config.platform,
        application: @config.application
      }

      # TODO: nest
      message.merge! trace.serialize

      exchange.publish JSON.dump(message),
        persistent: true,
        routing_key: 'mnemosyne.trace',
        content_type: 'application/json'
    end

    class << self
      def instance
        @instance ||= new
      end
    end
  end
end
