module Mnemosyne
  module Probes
    module ActionController
      class ProcessAction < ::Mnemosyne::Probe
        subscribe 'process_action.action_controller'

        def call(name, start, finish, id, payload)
          start  = ::Mnemosyne::Clock.to_tick(start)
          finish = ::Mnemosyne::Clock.to_tick(finish)

          span = ::Mnemosyne::Span.new("rails.#{name}", start: start, finish: finish, meta: payload)
          ::Mnemosyne.current_trace << span
        end
      end
    end

    register('ActionController::Base', 'action_controller', ActionController::ProcessAction.new)
  end
end
