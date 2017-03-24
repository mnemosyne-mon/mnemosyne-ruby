# frozen_string_literal: true

module Mnemosyne
  module Probes
    module Restify
      module Base
        class Probe < ::Mnemosyne::Probe
          def setup
            require 'mnemosyne/middleware/restify'

            ::Restify::Adapter::Base.prepend ::Mnemosyne::Middleware::Restify
          end
        end
      end
    end

    register 'Restify::Adapter::Base',
      'restify/adapter/base',
      Restify::Base::Probe.new
  end
end
