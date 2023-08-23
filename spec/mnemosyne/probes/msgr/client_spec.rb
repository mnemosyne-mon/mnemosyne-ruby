# frozen_string_literal: true

require 'spec_helper'
require 'support/msgr'

RSpec.describe Mnemosyne::Probes::Msgr::Consumer, probe: :msgr do
  let(:client) do
    Msgr::Client.new \
      size: 1,
      uri: ENV.fetch('AMQP_SERVER', 'amqp://localhost'),
      prefix: SecureRandom.hex(2),
      pool_class: '::Msgr::TestPool'
  end

  let(:message) { {} }

  before do
    Msgr.logger.level = 10
  end

  before do
    client.routes.configure do
      route 'test.index', to: 'test#index'
    end

    client.start
  end

  after do
    client.stop delete: true
    Msgr::TestPool.reset
  end

  describe 'Msgr.publish' do
    it 'create a span' do
      trace = with_trace do
        # Method signature is (data, opts = {})
        client.publish(message, {to: 'test.index'})
      end

      expect(trace.span.size).to eq 1

      trace.span.first.tap do |span|
        expect(span.name).to eq 'external.publish.msgr'
      end
    end
  end
end
