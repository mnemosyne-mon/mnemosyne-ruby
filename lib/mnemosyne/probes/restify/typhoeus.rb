# frozen_string_literal: true

module Mnemosyne
  module Probes
    module Restify
      module Typhoeus
        class Probe < ::Mnemosyne::Probe
          def setup
            require 'mnemosyne/middleware/restify'

            ::Restify::Adapter::Typhoeus.prepend Instrumentation
          end

          module Instrumentation
            def queue(request, writer)
              ::Mnemosyne::Middleware::Restify.call(request, writer) do |r, w|
                super(r, w)
              end
            end
          end
        end
      end
    end

    register 'Restify::Adapter::Typhoeus', 'restify/adapter/typhoeus',
      Restify::Typhoeus::Probe.new
  end
end
