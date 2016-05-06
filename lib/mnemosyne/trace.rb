module Mnemosyne
  class Trace
    attr_reader :uuid, :name

    def initialize(name)
      @name = name
      @uuid = ::SecureRandom.uuid
      @span = []

      @start_tick = ::Mnemosyne::Clock.tick
      @stop_tick = false
    end

    def <<(span)
      if finish?
        raise RuntimeError.new 'Cannot add span to ended trace.'
      else
        @span << span
      end
    end

    def finish
      return if finished?

      @stop_tick = ::Mnemosyne::Clock.tick
    end

    def finished?
      !!@stop_tick
    end

    def submit
      finish

      client.send self
    end

    def client
      ::Mnemosyne::Client.instance
    end

    def serialize
      {
        uuid: @uuid,
        name: @name,
        start_tick: @start_tick,
        stop_tick: @stop_tick,
        span: @span.map(&:serialize)
      }
    end
  end
end
