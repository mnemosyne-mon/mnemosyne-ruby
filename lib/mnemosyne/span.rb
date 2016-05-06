module Mnemosyne
  class Span
    attr_reader :name, :start_tick, :stop_tick

    def initialize(name)
      @name = name
    end

    def start_tick
      @start_tick = ::Mnemosyne::Clock.tick

      self
    end

    def stop_tick
      @stop_tick = ::Mnemosyne::Clock.tick

      self
    end

    def serialize
      {
        name: name,
        start_tick: stop_tick,
        stop_tick: stop_tick
      }
    end
  end
end
