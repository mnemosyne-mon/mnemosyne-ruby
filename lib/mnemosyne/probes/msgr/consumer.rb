# frozen_string_literal: true

module Mnemosyne
  module Probes
    module Msgr
      module Consumer
        NAME = 'app.messaging.receive.msgr'.freeze

        class Probe < ::Mnemosyne::Probe
          def setup
            ::Msgr::Consumer.send :prepend, Instrumentation
          end
        end

        module Instrumentation
          def dispatch(message) # rubocop:disable AbcSize
            route = message.route
            metadata = message.metadata
            delivery_info = message.delivery_info

            origin      = metadata.headers.delete('mnemosyne.origin')
            transaction = metadata.headers.delete('mnemosyne.transaction') do
              ::SecureRandom.uuid
            end

            trace = ::Mnemosyne::Instrumenter.trace NAME,
              transaction: transaction,
              origin: origin

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
