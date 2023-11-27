# frozen_string_literal: true

module Mnemosyne
  module Probes
    module ActionDispatch
      module ShowExceptions
        class Probe < ::Mnemosyne::Probe
          def setup
            ::ActionDispatch::ShowExceptions.prepend Instrumentation
          end

          module Instrumentation
            def render_exception(env, exception)
              if (trace = ::Mnemosyne::Instrumenter.current_trace)
                if exception.respond_to?(:unwrapped_exception) && exception.respond_to?(:exception)
                  # ActionDispatch::ExceptionWrapper
                  trace.attach_error(exception.exception)
                else
                  trace.attach_error(exception)
                end
              end

              super
            end
          end
        end
      end
    end

    register 'ActionDispatch::ShowExceptions',
      'action_dispatch/middleware/show_exceptions',
      ActionDispatch::ShowExceptions::Probe.new
  end
end
