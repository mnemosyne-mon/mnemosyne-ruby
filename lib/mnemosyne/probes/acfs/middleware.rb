# frozen_string_literal: true

module Mnemosyne
  module Probes
    module Acfs
      module Middleware
        CATEGORY = 'acfs.run'.freeze

        class Probe < ::Mnemosyne::Probe
          subscribe 'acfs.runner.sync_run'

          def setup
            require 'mnemosyne/middleware/acfs'

            ::Acfs::Runner.use ::Mnemosyne::Middleware::Acfs
          end

          def call(trace, name, start, finish, id, payload)
            start  = ::Mnemosyne::Clock.to_tick(start)
            finish = ::Mnemosyne::Clock.to_tick(finish)

            meta = {
              caller: payload[:controller],
            }

            span = ::Mnemosyne::Span.new 'acfs.runner.sync_run',
              start: start, finish: finish, meta: meta

            trace << span
          end
        end
      end
    end

    register 'Acfs::Runner', 'acfs/runner', Acfs::Middleware::Probe.new
  end
end
