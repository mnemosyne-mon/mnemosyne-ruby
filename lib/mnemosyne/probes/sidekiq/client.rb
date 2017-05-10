# frozen_string_literal: true

module Mnemosyne
  module Probes
    module Sidekiq
      module Client
        class Probe < ::Mnemosyne::Probe
          def setup
            ::Sidekiq.configure_client do |config|
              config.client_middleware do |chain|
                chain.prepend Middleware
              end
            end
          end
        end

        class Middleware
          def call(_worker, job, _queue, _redis)
            if (trace = ::Mnemosyne::Instrumenter.current_trace)
              meta = {
                worker: job['class'],
                queue: job['queue'],
                arguments: job['args'],
                raw: job.clone
              }

              span = ::Mnemosyne::Span.new('external.job.sidekiq', meta: meta)
              span.finish! oneshot: true

              job['mnemosyne.transaction'] = trace.transaction
              job['mnemosyne.origin'] = span.uuid

              trace << span
            end

            yield
          end
        end
      end
    end

    register 'Sidekiq::Client', 'sidekiq/client', Sidekiq::Client::Probe.new
  end
end
