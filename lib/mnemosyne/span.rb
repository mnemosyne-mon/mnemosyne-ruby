module Mnemosyne
  class Span
    attr_reader :name, :start, :stop, :meta

    def initialize(name)
      @name = name
      @meta = {}

      @start = false
      @stop  = false
    end

    def start!
      @start = ::Mnemosyne::Clock.tick
      self
    end

    def stop!
      @stop = ::Mnemosyne::Clock.tick
      self
    end

    def serialize
      {
        name: name,
        start: start,
        stop: stop,
        meta: meta
      }
    end
  end
end
