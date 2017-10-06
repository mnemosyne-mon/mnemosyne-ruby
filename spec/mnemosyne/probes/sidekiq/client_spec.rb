# frozen_string_literal: true

require 'spec_helper'
require 'support/sidekiq'

RSpec.describe Mnemosyne::Probes::Sidekiq::Client do
  it 'creates span' do
    trace = with_trace do
      HardWorker.perform_async('test')
    end

    expect(trace.span.size).to eq 1

    span = trace.span.first

    expect(span.name).to eq 'external.job.sidekiq'
    expect(span.meta[:worker]).to eq 'HardWorker'
    expect(span.meta[:queue]).to eq 'default'
    expect(span.meta[:arguments]).to eq %w[test]
  end

  it 'passes transaction and origin to worker' do
    origin = with_trace(transaction: 'abcde') do
      HardWorker.perform_async('test')
    end

    trace = with_instrumentation do
      HardWorker.drain
    end

    expect(trace.origin).to eq origin.span.first.uuid
    expect(trace.transaction).to eq 'abcde'
  end
end
