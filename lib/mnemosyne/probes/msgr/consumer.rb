# frozen_string_literal: true

module Mnemosyne
  module Probes
    module Msgr
      module Consumer
        class Probe < ::Mnemosyne::Probe
          def setup
            ::Msgr::Consumer.send :prepend, Instrumentation
          end
        end

        module Instrumentation
          def dispatch(message) # rubocop:disable AbcSize
            binding.pry

            super
          #   origin      = job.delete('mnemosyne.origin') { false }
          #   transaction = job.delete('mnemosyne.transaction') { uuid }

          #   meta = {
          #     raw: job,
          #     queue: queue,
          #     worker: worker.class.name,
          #     arguments: job['args']
          #   }

          #   trace = ::Mnemosyne::Instrumenter.trace 'app.job.perform.sidekiq',
          #     transaction: transaction,
          #     origin: origin,
          #     meta: meta

          #   trace.start! if trace

          #   yield
          # ensure
          #   if trace
          #     trace.submit
          #     trace.release
          #   end
          end
        end
      end
    end

    register 'Msgr::Consumer', 'msgr/consumer', Msgr::Consumer::Probe.new
  end
end
