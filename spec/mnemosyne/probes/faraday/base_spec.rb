# frozen_string_literal: true

require 'spec_helper'
require 'webmock/rspec'

RSpec.describe Mnemosyne::Probes::Faraday::Base do
  before do
    # Ensure Probes are loaded in case one spec without `with_instrumentation`
    # is executed first. In that case the probe would not have been loaded
    # otherwise but Faraday has already build and locks its default middleware
    # stack and the Probe cannot patch it anymore.
    ::Mnemosyne::Probes.activate!
    require 'faraday'
  end

  describe 'setup' do
    subject(:faraday) { Faraday.new }

    before do
      # Ensure Faraday finalizes its middleware stack
      faraday.app
    end

    it 'automatically installs middleware' do
      expect(faraday.builder.handlers).to eq [
        'Faraday::Request::UrlEncoded',
        'Mnemosyne::Middleware::Faraday',
        'Faraday::Adapter::NetHttp'
      ]
    end

    context 'with explicit middleware' do
      subject(:faraday) do
        Faraday.new do |faraday|
          faraday.request  :url_encoded
          faraday.use      :mnemosyne
          faraday.response :logger
          faraday.adapter  Faraday.default_adapter
        end
      end

      it 'does not add additional middleware' do
        expect(faraday.builder.handlers).to eq [
          'Faraday::Request::UrlEncoded',
          'Mnemosyne::Middleware::Faraday',
          'Faraday::Response::Logger',
          'Faraday::Adapter::NetHttp'
        ]
      end
    end
  end

  describe 'a GET request' do
    subject(:request) { Faraday.get 'http://google.com' }

    before do
      stub_request(:get, 'google.com')
        .to_return(status: 200, body: 'search')
    end

    it 'creates a span when tracing' do
      trace = with_trace { request }

      expect(trace.span.size).to eq 1

      span = trace.span.first

      expect(span.name).to eq 'external.http.faraday'
      expect(span.meta[:url]).to eq 'http://google.com'
      expect(span.meta[:method]).to eq :get
      expect(span.meta[:status]).to eq 200
    end

    it 'does not affect untraced requests' do
      expect(request).to be_success
    end
  end

  describe 'a POST request with body' do
    subject(:request) { Faraday.post 'http://google.com', {q: 'tracing'} }

    before do
      stub_request(:post, 'google.com')
        .with(body: hash_including(q: 'tracing'))
        .to_return(status: 200, body: 'search')
    end

    it 'creates a span when tracing' do
      trace = with_trace { request }

      expect(trace.span.size).to eq 1

      span = trace.span.first

      expect(span.name).to eq 'external.http.faraday'
      expect(span.meta[:url]).to eq 'http://google.com'
      expect(span.meta[:method]).to eq :post
      expect(span.meta[:status]).to eq 200
    end

    it 'does not affect untraced requests' do
      expect(request).to be_success
    end
  end
end
