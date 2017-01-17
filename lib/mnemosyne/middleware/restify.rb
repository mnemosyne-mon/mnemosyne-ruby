# frozen_string_literal: true

module Mnemosyne
  module Middleware
    module Restify
      class Writer
        def initialize(writer, trace, span)
          @writer = writer
          @trace = trace
          @span = span
        end

        def fulfill(*args)
          @span.finish!
          @trace << @span

          @writer.fulfill(*args)
        end

        def reject(*args)
          @span.finish!
          @trace << @span

          @writer.reject(*args)
        end
      end

      class << self
        # rubocop:disable Metrics/MethodLength
        def call(request, writer)
          if (trace = ::Mnemosyne::Instrumenter.current_trace)
            meta = {url: request.uri, method: request.method}

            span = ::Mnemosyne::Span.new('external.http.restify', meta: meta)
            span.start!

            request.headers['X-Mnemosyne-Transaction'] = trace.transaction
            request.headers['X-Mnemosyne-Origin'] = span.uuid

            hook = Writer.new(writer, trace, span)

            yield request, hook
          else
            yield request, writer
          end
        end
      end
    end
  end
end
