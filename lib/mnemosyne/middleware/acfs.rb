# frozen_string_literal: true

module Mnemosyne
  module Middleware
    class Acfs
      def initialize(app, *_)
        @app = app
      end

      # rubocop:disable Metrics/MethodLength
      def call(request)
        trace = ::Mnemosyne::Instrumenter.current_trace

        if trace
          span = ::Mnemosyne::Span.new('external.http.acfs',
            meta: extract_meta(request))

          span.start!

          request.headers['X-Mnemosyne-Transaction'] = trace.transaction
          request.headers['X-Mnemosyne-Origin'] = span.uuid
        end

        request.on_complete do |response, nxt|
          begin
            span.finish!
            trace << span
          ensure
            nxt.call(response)
          end
        end

        @app.call(request)
      end

      private

      def extract_meta(request)
        {
          method: request.method,
          url: request.url
        }
      end
    end
  end
end
