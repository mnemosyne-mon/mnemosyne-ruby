# frozen_string_literal: true

require 'spec_helper'
require 'webmock/rspec'

RSpec.describe Mnemosyne::Probes::Faraday::Base do
  it 'creates a span when tracing' do
    trace = with_trace do
      stub_request(:any, 'google.com')
        .to_return(status: 200, body: 'search')

      require 'faraday'
      Faraday.get 'http://google.com'
    end

    expect(trace.span.size).to eq 1

    span = trace.span.first

    expect(span.name).to eq 'external.http.faraday'
    expect(span.meta[:url]).to eq 'http://google.com'
    expect(span.meta[:method]).to eq :get
    expect(span.meta[:status]).to eq 200
  end

  it 'does not affect untraced requests' do
    stub_request(:any, 'google.com')
      .to_return(status: 200, body: 'search')

    require 'faraday'
    response = Faraday.get 'http://google.com'

    expect(response).to be_success
  end
end
