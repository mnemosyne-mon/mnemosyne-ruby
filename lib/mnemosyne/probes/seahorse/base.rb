# frozen_string_literal: true

module Mnemosyne
  module Probes
    module Seahorse
      module Base
        class Probe < ::Mnemosyne::Probe
          def setup
            require 'mnemosyne/probes/seahorse/plugin'

            ::Seahorse::Client::Base.add_plugin(Probes::Seahorse::Plugin)
          end
        end
      end
    end

    register 'Seahorse', 'seahorse', Seahorse::Base::Probe.new
  end
end
