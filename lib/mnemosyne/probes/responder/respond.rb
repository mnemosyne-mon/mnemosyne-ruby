# frozen_string_literal: true

module Mnemosyne
  module Probes
    module Responder
      module Respond
        class Probe < ::Mnemosyne::Probe
          subscribe 'respond.responders.mnemosyne'

          def setup
            ::ActionController::Responder.prepend \
              ::Mnemosyne::Probes::Responder::Respond::Instrumentation
          end

          def call(trace, _name, start, finish, _id, _payload)
            start  = ::Mnemosyne::Clock.to_tick(start)
            finish = ::Mnemosyne::Clock.to_tick(finish)

            span = ::Mnemosyne::Span.new(
              'app.responder.respond',
              start:,
              finish:
            )

            trace << span
          end
        end

        module Instrumentation
          def respond
            ::ActiveSupport::Notifications.instrument \
              'respond.responders.mnemosyne' do
              super
            end
          end
        end
      end
    end

    register 'ActionController::Responder',
      'action_controller/responder',
      Responder::Respond::Probe.new
  end
end
