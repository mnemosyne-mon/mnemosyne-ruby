# frozen_string_literal: true

module Mnemosyne
  module Middleware
    class Acfs
      def initialize(app, *_)
        @app = app
      end

      def call(request) # rubocop:disable MethodLength
        trace = ::Mnemosyne::Instrumenter.current_trace

        if trace
          span = ::Mnemosyne::Span.new('external.http.acfs',
            meta: extract_meta(request))

          span.start!

          request.headers['X-Mnemosyne-Transaction'] = trace.transaction
          request.headers['X-Mnemosyne-Origin'] = span.uuid

          request.on_complete do |response, nxt|
            span.finish!
            trace << span

            nxt.call(response)
          end
        end

        @app.call(request)
      end

      private

      def extract_meta(request)
        {
          url: request.url,
          method: request.method,
          params: request.params
        }
      end
    end
  end
end
