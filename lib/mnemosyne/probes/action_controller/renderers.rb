# frozen_string_literal: true

module Mnemosyne
  module Probes
    module ActionController
      module Renderers
        CATEGORY = 'render_to_body.renderers.action_controller'

        class Probe < ::Mnemosyne::Probe
          subscribe CATEGORY

          def setup
            ::ActionController::Base.prepend Instrumentation
          end

          def call(trace, _name, start, finish, _id, _payload)
            start  = ::Mnemosyne::Clock.to_tick(start)
            finish = ::Mnemosyne::Clock.to_tick(finish)

            span = ::Mnemosyne::Span.new(
              'app.controller.renderers.rails',
              start:,
              finish:
            )

            trace << span
          end
        end

        module Instrumentation
          def render_to_body(*args, &)
            ::ActiveSupport::Notifications.instrument CATEGORY do
              super
            end
          end
        end
      end
    end

    register 'ActionController::Base',
      'action_controller/metal/renderers',
      ActionController::Renderers::Probe.new
  end
end
