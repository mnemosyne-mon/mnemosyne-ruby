# frozen_string_literal: true

module Mnemosyne
  module Middleware
    class Rack
      class Proxy
        def initialize(body, &block)
          @body = body
          @block = block
          @closed = false
        end

        def respond_to_missing?(*args)
          return false if args.first && args.first.to_s == 'to_ary'.freeze

          @body.respond_to?(*args)
        end

        def method_missing(*args)
          super if args.first && args.first.to_s == 'to_ary'.freeze

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
            @block.call
          end
        end

        def closed?
          @closed
        end

        def each(*args)
          if block_given?
            @body.each(*args, &Proc.new)
          else
            @body.each(*args)
          end
        end
      end

      def initialize(app)
        @app = app
      end

      def call(env)
        transaction = env.fetch('HTTP_X_MNEMOSYNE_TRANSACTION') { ::SecureRandom.uuid }
        origin      = env.fetch('HTTP_X_MNEMOSYNE_ORIGIN', false)

        trace = ::Mnemosyne::Trace.new 'app.rack.request',
          transaction: transaction,
          origin: origin

        trace.start!

        ::Mnemosyne.current_trace = trace

        response = @app.call env

        response[2] = Proxy.new(response[2]) { trace.submit if trace }

        response
      rescue Exception
        trace.submit if trace
        raise
      end
    end
  end
end
