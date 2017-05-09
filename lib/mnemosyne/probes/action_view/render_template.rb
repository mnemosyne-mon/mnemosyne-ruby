# frozen_string_literal: true

module Mnemosyne
  module Probes
    module ActionView
      module RenderTemplate
        class Probe < ::Mnemosyne::Probe
          subscribe 'render_template.action_view'

          def call(trace, _name, start, finish, _id, payload)
            start  = ::Mnemosyne::Clock.to_tick(start)
            finish = ::Mnemosyne::Clock.to_tick(finish)

            span = ::Mnemosyne::Span.new 'view.render.template.rails',
              start: start, finish: finish, meta: payload

            trace << span
          end
        end
      end
    end

    register nil, nil, ActionView::RenderTemplate::Probe.new
  end
end
