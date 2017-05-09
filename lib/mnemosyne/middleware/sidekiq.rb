# frozen_string_literal: true

module Mnemosyne
  module Middleware
    class Sidekiq
      def call(worker, job, queue)
        origin      = job.delete('mnemosyne.origin') { false }
        transaction = job.delete('mnemosyne.transaction') { uuid }

        trace = ::Mnemosyne::Instrumenter.trace 'app.job.perform.sidekiq',
          transaction: transaction,
          origin: origin

        trace.meta[:worker] = worker.class.name
        trace.meta[:queue] = queue
        trace.meta[:job] = job

        trace.start! if trace

        yield
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
