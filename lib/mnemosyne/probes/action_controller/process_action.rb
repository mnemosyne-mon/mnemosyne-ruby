# frozen_string_literal: true

module Mnemosyne
  module Probes
    module ActionController
      module ProcessAction
        class Probe < ::Mnemosyne::Probe
          subscribe 'process_action.action_controller'

          def call(trace, _name, start, finish, _id, payload)
            start  = ::Mnemosyne::Clock.to_tick(start)
            finish = ::Mnemosyne::Clock.to_tick(finish)

            meta = {
              controller: payload[:controller],
              action: payload[:action],
              format: payload[:format]
            }

            span = ::Mnemosyne::Span.new(
              'app.controller.request.rails',
              start:,
              finish:,
              meta:
            )

            trace << span
          end
        end
      end
    end

    register 'ActionController::Base',
      'action_controller',
      ActionController::ProcessAction::Probe.new
  end
end
