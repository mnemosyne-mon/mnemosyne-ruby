# frozen_string_literal: true

require 'spec_helper'
require 'webmock/rspec'

RSpec.describe Mnemosyne::Probes::Seahorse::Base, probe: :seahorse do
  before { require 'aws-sdk-core' }

  describe 'a GET request with the S3 client' do
    subject(:request) do
      require 'aws-sdk-s3'
      client = Aws::S3::Client.new(stub_responses: true)
      client.get_object(bucket: 'foo', key: 'bar')
    end

    it 'creates a span when tracing' do
      trace = with_trace { request }

      expect(trace.span.size).to eq 1

      span = trace.span.first

      expect(span.name).to eq 'external.http.seahorse'
      expect(span.meta[:url]).to eq 'https://s3.us-stubbed-1.amazonaws.com'
      expect(span.meta[:method]).to eq :get
      expect(span.meta[:status]).to eq 200
    end

    it 'does not affect untraced requests' do
      expect(request).to be_successful
    end
  end
end
