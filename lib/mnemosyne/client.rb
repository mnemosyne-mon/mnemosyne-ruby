require 'bunny'

module Mnemosyne
  class Client
    def initialize
    end

    def connection
      @connection ||= begin
        conn = ::Bunny.new
        conn.start
        conn
      end
    end

    def channel
      @channel ||= connection.create_channel
    end

    def exchange
      @exchange ||= channel.topic 'mnemosyne', durable: true
    end

    def send(key, data)
      blob = JSON.dump data

      exchange.publish blob,
        routing_key: key,
        persistent: true,
        content_type: 'application/json'
    end

    class << self
      def instance
        @instance ||= self.new
      end
    end
  end
end
