# frozen_string_literal: true

module Mnemosyne
  module Probes
    module RedisClient
      module Command
        class Probe < ::Mnemosyne::Probe
          def setup
            ::RedisClient.register Instrumentation
          end

          module Instrumentation
            def call(command, redis_config)
              ::Mnemosyne::Support::Redis.instrument([command], redis_config.server_url) { super }
            end

            def call_pipelined(commands, redis_config)
              ::Mnemosyne::Support::Redis.instrument(commands, redis_config.server_url) { super }
            end
          end
        end
      end
    end

    register 'RedisClient',
      'redis_client',
      RedisClient::Command::Probe.new
  end
end
