# frozen_string_literal: true

module Mnemosyne
  class Span
    attr_reader :uuid, :name, :start, :finish, :meta, :type

    def initialize(name, start: false, finish: false, meta: {})
      @type = nil
      @name = name
      @meta = meta
      @uuid = ::SecureRandom.uuid

      @start  = start
      @finish = finish
    end

    def start!
      raise 'Already started' if @start

      @start = ::Mnemosyne::Clock.tick

      self
    end

    def finish!(oneshot: false)
      raise 'Already finished' if @finish

      @finish = ::Mnemosyne::Clock.tick

      if oneshot
        @start ||= @finish
        @type = :oneshot
      end

      self
    end

    def serialize
      {
        uuid: uuid,
        name: name,
        type: type,
        start: start,
        stop: finish,
        meta: meta
      }
    end
  end
end
