# frozen_string_literal: true

module Mnemosyne
  module Probes
    module Redis
      module Command
        class Probe < ::Mnemosyne::Probe
          def setup
            # Redis v5+ used redis-client, which has it's own probe
            return if Gem::Version.new(::Redis::VERSION) >= Gem::Version.new('5')

            ::Redis::Client.prepend ClientPatch
          end

          module ClientPatch
            def process(commands)
              ::Mnemosyne::Support::Redis.instrument(commands, id) { super }
            end
          end
        end
      end
    end

    register 'Redis::Client',
      'redis',
      Redis::Command::Probe.new
  end
end
