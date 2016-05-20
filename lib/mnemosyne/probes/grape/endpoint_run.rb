# frozen_string_literal: true

module Mnemosyne
  module Probes
    module Grape
      module EndpointRun
        class Probe < ::Mnemosyne::Probe
          subscribe 'endpoint_run.grape'

          def call(trace, name, start, finish, id, payload)
            start  = ::Mnemosyne::Clock.to_tick(start)
            finish = ::Mnemosyne::Clock.to_tick(finish)

            if endpoint = payload[:endpoint]
              span = ::Mnemosyne::Span.new 'app.controller.request.grape',
                start: start, finish: finish

              trace << span
            end
          end
        end
      end
    end

    register('Grape::Endpoint', 'grape/endpoint', Grape::EndpointRun::Probe.new)
  end
end
