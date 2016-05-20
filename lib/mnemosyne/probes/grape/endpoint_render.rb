# frozen_string_literal: true

module Mnemosyne
  module Probes
    module Grape
      module EndpointRender
        class Probe < ::Mnemosyne::Probe
          subscribe 'endpoint_render.grape'

          def call(trace, name, start, finish, id, payload)
            start  = ::Mnemosyne::Clock.to_tick(start)
            finish = ::Mnemosyne::Clock.to_tick(finish)

            if endpoint = payload[:endpoint]
              span = ::Mnemosyne::Span.new 'view.render.grape',
                start: start, finish: finish

              trace << span
            end
          end
        end
      end
    end

    register('Grape::Endpoint', 'grape/endpoint', Grape::EndpointRender::Probe.new)
  end
end
