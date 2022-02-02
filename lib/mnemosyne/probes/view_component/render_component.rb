# frozen_string_literal: true

module Mnemosyne
  module Probes
    module ViewComponent
      module RenderComponent
        class Probe < ::Mnemosyne::Probe
          subscribe '!render.view_component'

          def call(trace, _name, start, finish, _id, payload)
            start  = ::Mnemosyne::Clock.to_tick(start)
            finish = ::Mnemosyne::Clock.to_tick(finish)

            span = ::Mnemosyne::Span.new 'view.render.component.view_component',
              start: start, finish: finish, meta: payload

            trace << span
          end
        end
      end
    end

    register nil, nil, ViewComponent::RenderComponent::Probe.new
  end
end
