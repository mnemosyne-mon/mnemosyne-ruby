# frozen_string_literal: true

module Mnemosyne
  module Probes
    module ActiveRecord
      class Probe < ::Mnemosyne::Probe
        subscribe 'sql.active_record'

        def call(trace, name, start, finish, id, payload)
          return if payload[:name] == 'SCHEMA' || payload[:name] == 'CACHE'

          start  = ::Mnemosyne::Clock.to_tick(start)
          finish = ::Mnemosyne::Clock.to_tick(finish)

          meta = {
            sql: payload[:sql]
          }

          span = ::Mnemosyne::Span.new "db.query.active_record",
            start: start, finish: finish, meta: meta

          trace << span
        end
      end
    end

    register('ActiveRecord::Base', 'active_record', ActiveRecord::Probe.new)
  end
end
