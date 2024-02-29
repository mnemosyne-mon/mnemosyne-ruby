# frozen_string_literal: true

module Mnemosyne
  module Probes
    module ActiveRecord
      module Query
        class Probe < ::Mnemosyne::Probe
          subscribe 'sql.active_record'

          def call(trace, _name, start, finish, _id, payload)
            return if payload[:name] == 'SCHEMA' || payload[:name] == 'CACHE'

            start  = ::Mnemosyne::Clock.to_tick(start)
            finish = ::Mnemosyne::Clock.to_tick(finish)

            meta = {
              sql: payload[:sql],
              binds: extract_bind_values(payload)
            }

            span = ::Mnemosyne::Span.new(
              'db.query.active_record',
              start:,
              finish:,
              meta:
            )

            trace << span
          end

          def extract_bind_values(payload)
            return if payload[:binds].empty?

            payload[:binds].map do |bind|
              if bind.is_a?(Array)
                bind[0].type_cast_for_database(bind[1])
              else
                bind.value_for_database
              end
            end
          rescue StandardError
            []
          end
        end
      end
    end

    register 'ActiveRecord::Base',
      'active_record',
      ActiveRecord::Query::Probe.new
  end
end
