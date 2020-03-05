# frozen_string_literal: true

module Mnemosyne
  module Middleware
    class Rack
      class Proxy
        def initialize(body, trace)
          @body = body
          @trace = trace
          @closed = false
        end

        def respond_to_missing?(*args)
          return false if args.first && args.first.to_s == 'to_ary'

          @body.respond_to?(*args)
        end

        def method_missing(*args)
          super if args.first && args.first.to_s == 'to_ary'

          if block_given?
            @body.__send__(*args, &Proc.new)
          else
            @body.__send__(*args)
          end
        end

        def close
          return if @closed

          @closed = true

          begin
            @body.close if @body.respond_to? :close
          ensure
            _submit_trace
          end
        end

        def closed?
          @closed
        end

        def each(*args)
          @body.each(*args, &Proc.new)
        rescue StandardError, LoadError, SyntaxError => e
          @trace.attach_error(e)
          raise
        end

        private

        def _submit_trace
          @trace.submit
        rescue Exception => e # rubocop:disable Lint/RescueException
          ::Mnemosyne::Logging.logger.error \
            "Error while submitting trace: #{e}\n  #{e.backtrace.join("\n  ")}"
        end
      end

      def initialize(app)
        @app = app
      end

      def call(env)
        origin      = env.fetch('HTTP_X_MNEMOSYNE_ORIGIN', false)
        transaction = env.fetch('HTTP_X_MNEMOSYNE_TRANSACTION') do
          ::SecureRandom.uuid
        end

        trace = ::Mnemosyne::Instrumenter.trace 'app.web.request.rack',
          transaction: transaction,
          origin: origin

        if trace
          trace.start!

          scan_request(trace, env)

          response = @app.call env

          scan_response(trace, response)

          response[2] = Proxy.new(response[2], trace)
          response
        else
          @app.call env
        end
      rescue StandardError, LoadError, SyntaxError => e
        if trace
          trace.attach_error(e)
          trace.submit
        end

        raise
      ensure
        trace&.release
      end

      private

      def scan_request(trace, env)
        trace.meta[:method] = env['REQUEST_METHOD']
        trace.meta[:path] = env['REQUEST_PATH']
        trace.meta[:query] = env['QUERY_STRING']
        trace.meta[:protocol] = env['SERVER_PROTOCOL']
        trace.meta[:headers] = {
          'Accept': env['HTTP_ACCEPT'],
          'Host': env['HTTP_HOST'],
          'User-Agent': env['HTTP_USER_AGENT']
        }
      end

      def scan_response(trace, response)
        status, headers, = response

        trace.meta[:status] = status

        return unless headers

        trace.meta.merge!({
          content_type: headers['Content-Type'],
          location: headers['Location']
        }.compact)
      end
    end
  end
end
