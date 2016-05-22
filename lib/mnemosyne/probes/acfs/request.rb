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

          def call(trace, name, start, finish, id, payload)
            start  = ::Mnemosyne::Clock.to_tick(start)
            finish = ::Mnemosyne::Clock.to_tick(finish)

            callers = caller

            while !(callers[0].include? 'lib/acfs/global.rb:')
              callers.shift
            end

            meta = {
              backtrace: callers[1..-1]
            }

            span = ::Mnemosyne::Span.new 'external.run.acfs',
              start: start, finish: finish, meta: meta

            trace << span
          end
        end
      end
    end

    register 'Acfs::Runner', 'acfs/runner', Acfs::Request::Probe.new
  end
end
