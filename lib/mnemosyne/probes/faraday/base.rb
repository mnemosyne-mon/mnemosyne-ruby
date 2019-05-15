# frozen_string_literal: true

module Mnemosyne
  module Probes
    module Faraday
      module Base
        class Probe < ::Mnemosyne::Probe
          def setup
            ::Faraday.default_connection_options = {
              builder: ::Faraday::RackBuilder.new do |faraday|
                faraday.use Probe::Middleware
                faraday.request :url_encoded
                faraday.adapter ::Faraday.default_adapter
              end
            }
          end

          class Middleware
            def initialize(app)
              @app = app
            end

            def call(env)
              trace = ::Mnemosyne::Instrumenter.current_trace

              return @app.call(env) unless trace

              span = ::Mnemosyne::Span.new 'external.http.faraday', \
                meta: {url: env[:url].to_s, method: env[:method]}

              span.start!

              env[:request_headers].merge!({
                'X-Mnemosyne-Transaction' => trace.transaction,
                'X-Mnemosyne-Origin' => span.uuid,
              }.reject {|_, v| v.nil? })

              @app.call(env).on_complete do |env|
                span.meta[:status] = env[:status]

                trace << span.finish!
              end
            end
          end
        end
      end
    end

    register 'Faraday', 'faraday', Faraday::Base::Probe.new
  end
end
