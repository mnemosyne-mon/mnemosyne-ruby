module Mnemosyne
  class Trace < Span
    attr_reader :uuid

    def initialize(name)
      super name

      @uuid = ::SecureRandom.uuid
      @span = []
    end

    def <<(span)
      @span << span
    end

    def submit
      stop! unless stop

      client.send self
    end

    def client
      ::Mnemosyne::Client.instance
    end

    def serialize
      {
        uuid: uuid,
        name: name,
        start: start,
        stop: stop,
        meta: meta,
        span: @span.map(&:serialize)
      }
    end
  end
end
