# frozen_string_literal: true

module Mnemosyne
  module Probes
    module Mnemosyne
      module Tracer
        class Probe < ::Mnemosyne::Probe
          subscribe 'trace.mnemosyne'

          def call(trace, name, start, finish, id, payload)
            start  = ::Mnemosyne::Clock.to_tick(start)
            finish = ::Mnemosyne::Clock.to_tick(finish)

            span = ::Mnemosyne::Span.new 'custom.trace',
              start: start, finish: finish, meta: payload

            trace << span
          end
        end
      end
    end

    register(nil, nil, Mnemosyne::Tracer::Probe.new)
  end
end
