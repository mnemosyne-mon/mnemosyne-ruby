# frozen_string_literal: true

module Mnemosyne
  module Middleware
    module Restify
      def call(request)
        if (trace = ::Mnemosyne::Instrumenter.current_trace)
          meta = {url: request.uri.to_s, method: request.method}

          span = ::Mnemosyne::Span.new('external.http.restify', meta: meta)
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
