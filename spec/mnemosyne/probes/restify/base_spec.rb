# frozen_string_literal: true

require 'spec_helper'
require 'webmock/rspec'

RSpec.describe Mnemosyne::Probes::Restify::Base do
  before { require 'restify' }

  describe 'a GET request' do
    subject(:request) { Restify.new('http://google.com').get.value! }

    before do
      stub_request(:get, 'google.com')
        .to_return(status: 200, body: 'search')
    end

    it 'creates a span when tracing' do
      trace = with_trace { request }

      expect(trace.span.size).to eq 1

      span = trace.span.first

      expect(span.name).to eq 'external.http.restify'
      expect(span.meta[:url]).to eq 'http://google.com'
      expect(span.meta[:method]).to eq :get
      expect(span.meta[:status]).to eq 200
    end

    it 'does not affect untraced requests' do
      expect(request).to be
    end
  end
end
