# frozen_string_literal: true

require 'spec_helper'
require 'action_dispatch'
require 'action_view'

RSpec.describe Mnemosyne::Probes::ActionDispatch::ShowExceptions::Probe, probe: :rails do
  let(:exception_application) do
    ->(_env) { [200, {}, ''] }
  end

  let(:application) do
    raise_error = -> { raise error }
    exception_application = self.exception_application

    Rack::Builder.app do
      use ActionDispatch::ShowExceptions, exception_application
      run ->(_env) { raise_error.call }
    end
  end

  let(:mock) { Rack::MockRequest.new(application) }
  let(:error) { RuntimeError.new('ABC') }

  it 'attaches an exception' do
    trace = with_trace do
      mock.request
    end

    expect(trace.errors.size).to eq 1

    trace.errors.first.tap do |record|
      expect(record.error).to be error
    end
  end
end
