# frozen_string_literal: true

module Mnemosyne
  module Probes
    module Sidekiq
      module Client
        class Probe < ::Mnemosyne::Probe
          def setup
            ::Sidekiq.configure_server do |config|
              config.server_middleware do |chain|
                chain.prepend ::Mnemosyne::Middleware::Sidekiq
              end
            end
          end
        end
      end
    end

    register 'Sidekiq::Worker', 'sidekiq/worker', Sidekiq::Server::Probe.new
  end
end
