# frozen_string_literal: true

module Mnemosyne
  module Probes
    module ActiveRecord
      module Instantiation
        class Probe < ::Mnemosyne::Probe
          subscribe 'instantiation.active_record'

          def call(trace, _name, start, finish, _id, payload)
            start  = ::Mnemosyne::Clock.to_tick(start)
            finish = ::Mnemosyne::Clock.to_tick(finish)

            meta = {
              count: payload[:record_count],
              class_name: payload[:class_name]
            }

            span = ::Mnemosyne::Span.new(
              'db.instantiation.active_record',
              start:,
              finish:,
              meta:
            )

            trace << span
          end
        end
      end
    end

    register 'ActiveRecord::Base',
      'active_record',
      ActiveRecord::Instantiation::Probe.new
  end
end
