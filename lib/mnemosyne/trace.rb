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
      case error
        when Exception
          @errors << Error.new(error)
        when String
          @errors << Error.new(RuntimeError.new(error))
        else
          raise ArgumentError.new "Invalid error type: #{error.inspect}"
      end
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
        span: @span.map(&:serialize),
        errors: @errors.map(&:serialize)
      }
    end

    Error = Struct.new(:error) do
      BT_REGEXP = /^((?:[a-zA-Z]:)?[^:]+):(\d+)(?::in `([^']+)')?$/

      def serialize
        {
          type: error.class.name,
          text: error.message.to_s,
          stacktrace: serialize_backtrace
        }.compact
      end

      private

      def serialize_backtrace
        return unless error.backtrace

        error.backtrace.map do |bt|
          md = BT_REGEXP.match(bt.to_s).to_a

          {file: md[1], line: md[2], call: md[3], raw: md[0]}
        end
      end
    end
  end
end
