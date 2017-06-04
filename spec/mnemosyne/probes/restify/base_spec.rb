# frozen_string_literal: true

require 'spec_helper'
require 'webmock/rspec'
require 'restify'

RSpec.describe Mnemosyne::Probes::Restify::Base do
  it 'creates span' do
    trace = with_trace do
      stub_request(:any, 'google.com')

      Restify.new('http://google.com').get.value!
    end

    expect(trace.span.size).to eq 1

    span = trace.span.first

    expect(span.name).to eq 'external.http.restify'
    expect(span.meta[:url]).to eq 'http://google.com'
    expect(span.meta[:method]).to eq :get
  end
end
