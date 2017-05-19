# frozen_string_literal: true

require 'spec_helper'
require 'support/sidekiq'

RSpec.describe Mnemosyne::Probes::Sidekiq::Server do
  it 'creates a trace' do
    trace = with_instrumentation do
      HardWorker.perform_async('test')
      HardWorker.drain
    end

    expect(trace.name).to eq 'app.job.perform.sidekiq'
    expect(trace.meta[:worker]).to eq 'HardWorker'
    expect(trace.meta[:queue]).to eq 'default'
    expect(trace.meta[:arguments]).to eq %w(test)
  end
end
