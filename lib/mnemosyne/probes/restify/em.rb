# frozen_string_literal: true

module Mnemosyne
  module Probes
    module Restify
      module EM
        class Probe < ::Mnemosyne::Probe
          def setup
            require 'mnemosyne/middleware/restify'

            ::Restify::Adapter::EM::Connection.prepend Instrumentation
          end

          module Instrumentation
            def call(request, writer, *args)
              ::Mnemosyne::Middleware::Restify.call(request, writer) do |r, w|
                super(r, w, *args)
              end
            end
          end
        end
      end
    end

    register 'Restify::Adapter::EM::Connection', 'restify/adapter/em',
      Restify::EM::Probe.new
  end
end
