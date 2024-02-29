# frozen_string_literal: true

module Mnemosyne
  module Middleware
    class Sidekiq
      def call(worker, job, queue)
        origin      = job.delete('mnemosyne.origin') { false }
        transaction = job.delete('mnemosyne.transaction') { uuid }

        meta = {
          raw: job,
          queue:,
          worker: worker.class.name,
          arguments: job['args']
        }

        trace = ::Mnemosyne::Instrumenter.trace(
          'app.job.perform.sidekiq',
          transaction:,
          origin:,
          meta:
        )

        trace&.start!

        yield
      rescue StandardError, LoadError, SyntaxError => e
        trace.attach_error(e)
        raise
      ensure
        if trace
          trace.submit
          trace.release
        end
      end

      private

      def uuid
        ::SecureRandom.uuid
      end
    end
  end
end
