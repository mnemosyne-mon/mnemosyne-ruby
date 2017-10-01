# frozen_string_literal: true

module Mnemosyne
  module Middleware
    class Sidekiq
      def call(worker, job, queue)
        origin      = job.delete('mnemosyne.origin') { false }
        transaction = job.delete('mnemosyne.transaction') { uuid }

        meta = {
          raw: job,
          queue: queue,
          worker: worker.class.name,
          arguments: job['args']
        }

        trace = ::Mnemosyne::Instrumenter.trace 'app.job.perform.sidekiq',
          transaction: transaction,
          origin: origin,
          meta: meta

        trace.start! if trace

        yield
      rescue StandardError, LoadError, SyntaxError => err # rubocop:disable RescueException
        trace.attach_error(err)
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
