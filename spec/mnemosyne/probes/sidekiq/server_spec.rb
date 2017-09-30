# frozen_string_literal: true

require 'spec_helper'
require 'support/sidekiq'

RSpec.describe ::Mnemosyne::Probes::Sidekiq::Server do
  it 'creates a trace' do
    trace = with_instrumentation do
      HardWorker.perform_async('test')
      HardWorker.drain
    end

    expect(trace.name).to eq 'app.job.perform.sidekiq'
    expect(trace.meta[:worker]).to eq 'HardWorker'
    expect(trace.meta[:queue]).to eq 'default'
    expect(trace.meta[:arguments]).to eq %w[test]
  end

  it 'reports errors' do
    trace = with_instrumentation do
      FailWorker.perform_async('fail')

      begin
        FailWorker.drain
      rescue RuntimeError
        nil
      end
    end

    expect(trace.name).to eq 'app.job.perform.sidekiq'

    trace.errors.tap do |errors|
      expect(errors).to be_an Array
      expect(errors.size).to eq 1

      errors.first.tap do |error|
        expect(error).to be_a RuntimeError
        expect(error.message).to eq 'fail'
      end
    end
  end
end
