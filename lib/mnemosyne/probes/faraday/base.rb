# frozen_string_literal: true

module Mnemosyne
  module Probes
    module Faraday
      module Base
        class Probe < ::Mnemosyne::Probe
          def setup
            require 'mnemosyne/middleware/faraday'

            ::Faraday::Middleware.register_middleware \
              mnemosyne: ::Mnemosyne::Middleware::Faraday

            ::Faraday::RackBuilder.prepend Extension
          end
        end

        module Extension
          def lock!
            unless @handlers.include?('Mnemosyne::Middleware::Faraday')
              if ::Faraday::VERSION < '1.0' &&
                respond_to?(:is_adapter?, true) &&
                idx = @handlers.find_index {|m| is_adapter?(m) }

                insert(idx, ::Mnemosyne::Middleware::Faraday)
              else
                use(::Mnemosyne::Middleware::Faraday)
              end
            end

            super
          end
        end
      end
    end

    register 'Faraday', 'faraday', Faraday::Base::Probe.new
  end
end
