# frozen_string_literal: true

require 'spec_helper'
require 'support/sidekiq'
require 'support/active_job'

RSpec.describe Mnemosyne::Probes::ActiveJob::Perform, probe: :rails do
  context 'adapter: sidekiq' do
    it 'creates a trace' do
      trace = with_instrumentation do
        HardJob.perform_later('test')

        ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper.drain
      end

      expect(trace.span.size).to eq 1

      trace.span.first.tap do |span|
        expect(span.name).to eq 'app.job.perform.active_job'
        expect(span.meta.keys).to match_array %i[id job queue arguments]
        expect(span.meta).to include \
          id: anything,
          job: 'HardJob',
          queue: 'default',
          arguments: ['test']
      end
    end

    it 'reports errors' do
      trace = with_instrumentation do
        FailJob.perform_later('fail')

        begin
          ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper.drain
        rescue RuntimeError
          nil
        end
      end

      expect(trace.name).to eq 'app.job.perform.sidekiq'

      trace.errors.tap do |errors|
        expect(errors).to be_an Array
        expect(errors.size).to eq 1

        errors.first.tap do |error|
          expect(error.error).to be_a RuntimeError
          expect(error.error.message).to eq 'fail'
        end
      end
    end
  end
end
