# frozen_string_literal: true

module Mnemosyne
  module Probes
    module Grape
      module EndpointRun
        class Probe < ::Mnemosyne::Probe
          subscribe 'endpoint_run.grape'

          def call(trace, _name, start, finish, _id, payload)
            start  = ::Mnemosyne::Clock.to_tick(start)
            finish = ::Mnemosyne::Clock.to_tick(finish)

            endpoint = payload[:endpoint]
            return unless endpoint

            meta = {
              endpoint: extract_name(endpoint),
              format: extract_format(payload[:env])
            }

            span = ::Mnemosyne::Span.new(
              'app.controller.request.grape',
              start:,
              finish:,
              meta:
            )

            trace << span
          end

          private

          def extract_name(endpoint)
            endpoint.options[:for].to_s
          end

          def extract_format(env)
            env['api.format']
          end
        end
      end
    end

    register 'Grape::Endpoint',
      'grape/endpoint',
      Grape::EndpointRun::Probe.new
  end
end
