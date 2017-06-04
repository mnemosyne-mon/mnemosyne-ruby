# frozen_string_literal: true

module Mnemosyne
  module Probes
    module Restify
      module Base
        class Probe < ::Mnemosyne::Probe
          def setup
            ::Restify::Adapter::Base.prepend Instrumentation
          end

          module Instrumentation
            def call(request)
              if (trace = ::Mnemosyne::Instrumenter.current_trace)
                meta = {url: request.uri.to_s, method: request.method}

                span = ::Mnemosyne::Span.new 'external.http.restify', \
                  meta: meta

                span.start!

                request.headers['X-Mnemosyne-Transaction'] = trace.transaction
                request.headers['X-Mnemosyne-Origin'] = span.uuid

                super.tap do |x|
                  x.add_observer do |_, _response, _err|
                    span.finish!
                    trace << span
                  end
                end
              else
                super
              end
            end
          end
        end
      end
    end

    register 'Restify::Adapter::Base',
      'restify/adapter/base',
      Restify::Base::Probe.new
  end
end
