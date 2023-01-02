# frozen_string_literal: true

require 'spec_helper'

ENV['RAILS_ENV'] = 'test'

require 'mnemosyne/railtie'

class Dummy < Rails::Application
  config.eager_load = false
  config.paths['config'] << File.join(__dir__, '../dummy/config')
end

RSpec.describe Mnemosyne::Railtie do
  let(:railtie) { described_class.instance }

  describe '<initializer>' do
    it 'starts instrumenter with loaded config' do
      expect(Mnemosyne::Instrumenter).to receive(:start!) do |config|
        expect(config).to be_a Mnemosyne::Configuration

        expect(config).to be_enabled
        expect(config.server).to eq 'amqp://guest@test-server'
        expect(config.application).to eq 'Dummy'
      end

      Rails.application.initialize!
    end
  end
end
