# frozen_string_literal: true

module Mnemosyne
  module Middleware
    class Sidekiq
      def call(worker, job, queue) # rubocop:disable MethodLength, AbcSize
        mnemosyne = job.delete('mnemosyne')
        mnemosyne = {} unless mnemosyne.is_a?(Hash)

        origin      = mnemosyne.fetch('origin', false)
        transaction = mnemosyne.fetch('transaction') { ::SecureRandom.uuid }

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
    end
  end
end
