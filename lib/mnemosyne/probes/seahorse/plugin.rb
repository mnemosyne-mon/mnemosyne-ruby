# frozen_string_literal: true

require 'aws-sdk-core'

module Mnemosyne
  module Probes
    module Seahorse
      class Plugin < ::Seahorse::Client::Plugin
        def add_handlers(handlers, _config)
          handlers.add(Handler, step: :build)
        end

        class Handler < ::Seahorse::Client::Handler
          # @param [RequestContext] context
          # @return [Response]
          def call(context)
            trace = ::Mnemosyne::Instrumenter.current_trace

            return @handler.call(context) unless trace

            req = context.http_request
            span = ::Mnemosyne::Span.new 'external.http.seahorse', \
              meta: {
                url: req.endpoint.to_s,
                method: req.http_method.downcase.to_sym
              }

            span.start!

            req.headers.update({
              'X-Mnemosyne-Transaction' => trace.transaction,
              'X-Mnemosyne-Origin' => span.uuid
            }.reject {|_, v| v.nil? })

            @handler.call(context).tap do |response|
              res = response.context.http_response
              span.meta[:status] = res.status_code

              trace << span.finish!
            end
          end
        end
      end
    end
  end
end
