# frozen_string_literal: true

module Mnemosyne
  module Probes
    module ActionController
      module Renderers
        CATEGORY = 'render_to_body.renderers.action_controller'.freeze

        class Probe < ::Mnemosyne::Probe
          subscribe CATEGORY

          def setup
            ::ActionController::Base.prepend Instrumentation
          end

          def call(trace, name, start, finish, id, payload)
            start  = ::Mnemosyne::Clock.to_tick(start)
            finish = ::Mnemosyne::Clock.to_tick(finish)

            span = ::Mnemosyne::Span.new "rails.#{name}",
              start: start, finish: finish

            trace << span
          end
        end

        module Instrumentation
          def render_to_body(*args, &block)
            p 'render_to_body'
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
