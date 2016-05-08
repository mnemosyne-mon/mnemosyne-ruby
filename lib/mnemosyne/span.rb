module Mnemosyne
  class Span
    attr_reader :uuid, :name, :start, :finish, :meta

    def initialize(name, start: false, finish: false, meta: {})
      @name = name
      @meta = meta
      @uuid = ::SecureRandom.uuid

      @start  = start
      @finish = finish
    end

    def start!
      @start = ::Mnemosyne::Clock.tick
      self
    end

    def finish!
      @finish = ::Mnemosyne::Clock.tick
      self
    end

    def serialize
      {
        uuid: uuid,
        name: name,
        start: start,
        stop: finish,
        meta: meta
      }
    end
  end
end
