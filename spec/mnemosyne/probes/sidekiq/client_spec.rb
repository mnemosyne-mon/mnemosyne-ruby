# frozen_string_literal: true

require 'spec_helper'
require 'sidekiq'
require 'sidekiq/testing'

require 'mnemosyne/middleware/sidekiq'

Sidekiq::Testing.server_middleware do |chain|
  chain.add ::Mnemosyne::Middleware::Sidekiq
end

class HardWorker
  include Sidekiq::Worker

  def perform(message)
    # noop
  end
end

RSpec.describe Mnemosyne::Probes::Sidekiq::Client do
  it 'creates span' do
    trace = with_tracing do
      HardWorker.perform_async('test')
    end

    expect(trace.span.size).to eq 1

    span = trace.span.first

    expect(span.name).to eq 'external.job.sidekiq'
    expect(span.meta[:worker]).to eq 'HardWorker'
    expect(span.meta[:queue]).to eq 'default'
    expect(span.meta[:arguments]).to eq %w(test)
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
