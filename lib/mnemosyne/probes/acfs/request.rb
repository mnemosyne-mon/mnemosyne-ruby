# frozen_string_literal: true

module Mnemosyne
  module Probes
    module Acfs
      module Request
        class Probe < ::Mnemosyne::Probe
          subscribe 'acfs.run'

          def setup
            require 'mnemosyne/middleware/acfs'

            ::Acfs::Runner.use ::Mnemosyne::Middleware::Acfs
          end

          def call(trace, _name, start, finish, _id, _payload)
            start  = ::Mnemosyne::Clock.to_tick(start)
            finish = ::Mnemosyne::Clock.to_tick(finish)

            callers = caller

            callers.shift until callers[0].include? 'lib/acfs/global.rb:'

            meta = {
              backtrace: callers[1..]
            }

            span = ::Mnemosyne::Span.new(
              'external.run.acfs',
              start:,
              finish:,
              meta:
            )

            trace << span
          end
        end
      end
    end

    register 'Acfs::Runner', 'acfs/runner', Acfs::Request::Probe.new
  end
end
