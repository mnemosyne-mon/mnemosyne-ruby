# frozen_string_literal: true

module Mnemosyne
  module Probes
    module Msgr
      module Client
        NAME = 'external.publish.msgr'

        class Probe < ::Mnemosyne::Probe
          def setup
            ::Msgr::Client.prepend Instrumentation
          end
        end

        module Instrumentation
          def publish(payload, options = {})
            if (trace = ::Mnemosyne::Instrumenter.current_trace)
              meta = {}
              span = ::Mnemosyne::Span.new(NAME, meta: meta)
              span.start!

              options[:headers] ||= {}
              options[:headers][:'mnemosyne.transaction'] = trace.transaction
              options[:headers][:'mnemosyne.origin'] = span.uuid

              begin
                super
              ensure
                span.finish!
                trace << span
              end
            else
              super
            end
          end
        end
      end
    end

    register 'Msgr::Client', 'msgr/client', Msgr::Client::Probe.new
  end
end
