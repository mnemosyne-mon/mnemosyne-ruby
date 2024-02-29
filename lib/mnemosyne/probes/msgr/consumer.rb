# frozen_string_literal: true

module Mnemosyne
  module Probes
    module Msgr
      module Consumer
        NAME = 'app.messaging.receive.msgr'

        class Probe < ::Mnemosyne::Probe
          def setup
            ::Msgr::Consumer.prepend Instrumentation
          end
        end

        module Instrumentation
          def dispatch(message)
            route = message.route
            metadata = message.metadata
            headers = metadata.headers || {}
            delivery_info = message.delivery_info

            origin      = headers.delete('mnemosyne.origin')
            transaction = headers.delete('mnemosyne.transaction') do
              ::SecureRandom.uuid
            end

            trace = ::Mnemosyne::Instrumenter.trace(
              NAME,
              transaction:,
              origin:
            )

            if trace
              trace.meta[:properties] = {
                content_type: metadata.content_type,
                priority: metadata.priority,
                headers: metadata.headers,
                type: metadata.type,
                reply_to: metadata.reply_to,
                correlation_id: metadata.correlation_id,
                message_id: metadata.message_id,
                app_id: metadata.app_id
              }

              trace.meta[:delivery_info] = {
                consumer_tag: delivery_info.consumer_tag,
                redelivered: delivery_info.redelivered?,
                routing_key: delivery_info.routing_key,
                exchange: delivery_info.exchange
              }

              trace.meta[:route] = {
                consumer: route.consumer,
                action: route.action
              }

              trace.start!
            end

            super
          rescue StandardError, LoadError, SyntaxError => e
            trace&.attach_error(e)
            raise
          ensure
            if trace
              trace.submit
              trace.release
            end
          end
        end
      end
    end

    register 'Msgr::Consumer', 'msgr/consumer', Msgr::Consumer::Probe.new
  end
end
