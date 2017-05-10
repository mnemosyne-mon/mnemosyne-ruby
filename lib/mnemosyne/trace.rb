# frozen_string_literal: true

module Mnemosyne
  class Trace < Span
    attr_reader :uuid, :transaction, :origin, :span

    def initialize(instrumenter, name, transaction: nil, origin: nil)
      super name

      @uuid = ::SecureRandom.uuid
      @span = []

      @origin      = origin
      @transaction = transaction

      @instrumenter = instrumenter
    end

    def <<(span)
      @span << span
    end

    def submit
      finish! unless finish

      @instrumenter.submit self
    end

    def release
      @instrumenter.release self
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
