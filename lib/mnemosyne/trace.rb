module Mnemosyne
  class Trace < Span
    attr_reader :uuid, :transaction, :origin

    def initialize(name, transaction: nil, origin: nil)
      super name

      @uuid = ::SecureRandom.uuid
      @span = []

      @origin      = origin
      @transaction = transaction
    end

    def <<(span)
      @span << span
    end

    def submit
      finish! unless finish

      client.send self
    end

    def client
      ::Mnemosyne::Client.instance
    end

    def serialize
      {
        uuid: uuid,
        origin: origin,
        transaction: transaction,
        name: name,
        start: start,
        stop: finish,
        meta: meta,
        span: @span.map(&:serialize)
      }
    end
  end
end
