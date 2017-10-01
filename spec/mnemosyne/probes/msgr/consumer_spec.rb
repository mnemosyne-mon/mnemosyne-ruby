# frozen_string_literal: true

require 'spec_helper'
require 'support/msgr'

RSpec.describe ::Mnemosyne::Probes::Msgr::Consumer do
  let(:client) do
    ::Msgr::Client.new \
      size: 1,
      prefix: ::SecureRandom.hex(2),
      pool_class: '::Msgr::TestPool'
  end

  let(:message) { {} }

  before do
    client.routes.configure do
      route 'test.index', to: 'test#index'
      route 'test.error', to: 'test#error'
    end

    client.start
  end

  after do
    client.stop delete: true
    ::Msgr::TestPool.reset
  end

  it 'creates a trace' do
    trace = with_instrumentation do
      client.publish message, to: 'test.index'
      ::Msgr::TestPool.run
    end

    expect(trace.name).to eq 'app.messaging.receive.msgr'

    expect(trace.meta[:route]).to eq \
      action: 'index',
      consumer: 'TestConsumer'

    trace.meta[:delivery_info].tap do |delivery_info|
      expect(delivery_info.keys).to match_array \
        %i[consumer_tag redelivered routing_key exchange]

      expect(delivery_info[:consumer_tag]).to_not be_empty
      expect(delivery_info[:redelivered]).to eq false
      expect(delivery_info[:routing_key]).to eq 'test.index'
      expect(delivery_info[:exchange]).to match(/^[0-9a-f]{4}-msgr$/)
    end

    expect(trace.meta[:properties]).to eq \
      app_id: nil,
      content_type: 'application/json',
      correlation_id: nil,
      headers: nil,
      message_id: nil,
      priority: 0,
      reply_to: nil,
      type: nil
  end

  it 'reports errors' do
    trace = with_instrumentation do
      begin
        client.publish message, to: 'test.error'
        ::Msgr::TestPool.run
      rescue RuntimeError
        nil
      end
    end

    expect(trace.name).to eq 'app.messaging.receive.msgr'

    trace.errors.tap do |errors|
      expect(errors).to be_an Array
      expect(errors.size).to eq 1

      errors.first.tap do |error|
        expect(error).to be_a RuntimeError
        expect(error.message).to eq 'error'
      end
    end
  end
end
