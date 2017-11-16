# frozen_string_literal: true

module Mnemosyne
  module Probes
    module ActiveJob
      module Perform
        class Probe < ::Mnemosyne::Probe
          subscribe 'perform.active_job'

          def call(trace, _name, start, finish, _id, payload)
            start  = ::Mnemosyne::Clock.to_tick(start)
            finish = ::Mnemosyne::Clock.to_tick(finish)

            job = payload[:job]

            meta = {
              id: job.job_id,
              job: job.class.name,
              arguments: job.arguments,
              queue: job.queue_name
            }

            span = ::Mnemosyne::Span.new 'app.job.perform.active_job',
              start: start, finish: finish, meta: meta

            trace << span
          end
        end
      end
    end

    register 'ActiveJob::Base',
      'active_job',
      ActiveJob::Perform::Probe.new
  end
end
