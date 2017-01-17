# frozen_string_literal: true

module Mnemosyne
  module Probes
    module Grape
      module EndpointRunFilters
        class Probe < ::Mnemosyne::Probe
          subscribe 'endpoint_run_filters.grape'

          # rubocop:disable Metrics/ParameterLists
          def call(trace, _name, start, finish, _id, payload)
            start  = ::Mnemosyne::Clock.to_tick(start)
            finish = ::Mnemosyne::Clock.to_tick(finish)

            endpoint = payload[:endpoint]
            return unless endpoint

            span = ::Mnemosyne::Span.new 'app.controller.filter.grape',
              start: start, finish: finish

            trace << span
          end
        end
      end
    end

    register 'Grape::Endpoint',
      'grape/endpoint',
      Grape::EndpointRunFilters::Probe.new
  end
end
