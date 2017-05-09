# frozen_string_literal: true

module Mnemosyne
  module Middleware
    module Restify
      def call(request) # rubocop:disable MethodLength
        if (trace = ::Mnemosyne::Instrumenter.current_trace)
          meta = {url: request.uri, method: request.method}

          span = ::Mnemosyne::Span.new('external.http.restify', meta: meta)
          span.start!

          request.headers['X-Mnemosyne-Transaction'] = trace.transaction
          request.headers['X-Mnemosyne-Origin'] = span.uuid

          super.then do |response|
            span.finish!
            trace << span

            response
          end
        else
          super
        end
      end
    end
  end
end
