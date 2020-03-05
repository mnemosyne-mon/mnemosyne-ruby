# frozen_string_literal: true

require 'faraday'

module Mnemosyne
  module Middleware
    class Faraday < ::Faraday::Middleware
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
          'X-Mnemosyne-Origin' => span.uuid
        }.reject {|_, v| v.nil? })

        @app.call(env).on_complete do |env| # rubocop:disable Lint/ShadowingOuterLocalVariable
          span.meta[:status] = env[:status]

          trace << span.finish!
        end
      end
    end
  end
end
