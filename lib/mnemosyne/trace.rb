# frozen_string_literal: true

module Mnemosyne
  class Trace < Span
    attr_reader :uuid, :transaction, :origin, :span, :errors

    def initialize(instrumenter, name, transaction: nil, origin: nil, **kwargs)
      super(name, **kwargs)

      @uuid   = ::SecureRandom.uuid
      @span   = []
      @errors = []

      @origin      = origin
      @transaction = transaction

      @instrumenter = instrumenter
    end

    def <<(span)
      @span << span
    end

    def attach_error(error)
      @errors << error
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
