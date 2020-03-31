# frozen_string_literal: true

require 'spec_helper'
require 'webmock/rspec'

RSpec.describe Mnemosyne::Probes::Seahorse::Base, probe: :seahorse do
  before { require 'aws-sdk-core' }

  describe 'setup' do
    # TODO: Test that e.g. the S3 library is affected as well?
  end

  describe 'a GET request' do
    subject(:request) { client.build_request(:get_object).send_request }
    let(:client) { Seahorse::Client::Base.new(endpoint: 'http://s3.example.com') }

    let!(:api) do
      Seahorse::Client::Base.set_api(Seahorse::Model::Api.new.tap do |api|
        api.add_operation(:get_object, Seahorse::Model::Operation.new.tap do |o|
          o.name = 'GetObject'
          o.http_method = 'GET'
          o.http_request_uri = '/{Bucket}/{Key+}'
        end)
      end)
    end

    before do
      stub_request(:get, 's3.example.com')
        .to_return(status: 200, body: 's3-list')
    end

    it 'creates a span when tracing' do
      trace = with_trace { request }

      expect(trace.span.size).to eq 1

      span = trace.span.first

      expect(span.name).to eq 'external.http.seahorse'
      expect(span.meta[:url]).to eq 'http://s3.example.com'
      expect(span.meta[:method]).to eq :get
      expect(span.meta[:status]).to eq 200
    end

    it 'does not affect untraced requests' do
      expect(request).to be_successful
    end
  end
end
