# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mnemosyne::Configuration do
  let(:params) { {'application' => 'abc'} }
  let(:config) { described_class.new(params) }
  subject { config }

  before do
    allow(Socket).to receive(:gethostname).and_return('testhost')
  end

  describe '#initialize' do
    subject { -> { config } }

    context 'without application' do
      let(:params) { {} }
      it { is_expected.to raise_error ArgumentError, 'Application is required' }
    end

    context 'with empty application' do
      let(:params) { {'application' => ''} }
      it { is_expected.to raise_error ArgumentError, 'Application is required' }
    end

    context 'with blank application' do
      let(:params) { {'application' => " \t\n"} }
      it { is_expected.to raise_error ArgumentError, 'Application is required' }
    end

    context 'with empty hostname' do
      let(:params) { super().merge 'hostname' => '' }
      it { is_expected.to raise_error ArgumentError, 'Hostname is required' }
    end

    context 'with blank hostname' do
      let(:params) { super().merge 'hostname' => " \t\n" }
      it { is_expected.to raise_error ArgumentError, 'Hostname is required' }
    end

    context 'with invalid platform (I)' do
      let(:params) { {'platform' => 'helö'} }
      it do
        is_expected.to raise_error ArgumentError,
          'Platform may only contain alphanumeric characters'
      end
    end

    context 'with invalid platform (II)' do
      let(:params) { {'platform' => '-abc'} }
      it do
        is_expected.to raise_error ArgumentError,
          'Platform must start and end with a alphanumeric characters'
      end
    end

    context 'with invalid platform (III)' do
      let(:params) { {'platform' => 'a-b-c-'} }
      it do
        is_expected.to raise_error ArgumentError,
          'Platform must start and end with a alphanumeric characters'
      end
    end

    context 'with blank platform' do
      let(:params) { {'platform' => ''} }
      it { is_expected.to raise_error ArgumentError, 'Platform is required' }
    end
  end

  describe '#platform' do
    subject { config.platform }

    it { is_expected.to eq 'default' }

    context 'with valid value (I)' do
      let(:params) { super().merge 'platform' => 'platform' }
      it { is_expected.to eq 'platform' }
    end

    context 'with valid value (II)' do
      let(:params) { super().merge 'platform' => 'platform-id' }
      it { is_expected.to eq 'platform-id' }
    end

    context 'with valid value (III)' do
      let(:params) { super().merge 'platform' => 'platform-id-2' }
      it { is_expected.to eq 'platform-id-2' }
    end
  end

  describe '#application' do
    subject { config.application }

    context 'when configured' do
      let(:params) { super().merge 'application' => 'application-id' }
      it { is_expected.to eq 'application-id' }
    end

    context 'when spaced' do
      let(:params) { super().merge 'application' => " app-id\t" }
      it { is_expected.to eq 'app-id' }
    end
  end

  describe '#enabled' do
    subject { config.enabled? }

    it { is_expected.to be true }

    context 'when configured' do
      let(:params) { super().merge 'enabled' => false }
      it { is_expected.to be false }
    end
  end

  describe '#hostname' do
    subject { config.hostname }

    it { is_expected.to eq 'testhost' }

    context 'when configured' do
      let(:params) { super().merge 'hostname' => 'my-host' }
      it { is_expected.to eq 'my-host' }
    end

    context 'when spaced' do
      let(:params) { super().merge 'hostname' => " my-host\t" }
      it { is_expected.to eq 'my-host' }
    end
  end

  describe '#amqp' do
    subject { config.amqp }

    it 'defaults to AMQP default on localhost' do
      is_expected.to eq AMQ::Settings.configure('amqp://localhost')
    end

    context 'when configured' do
      let(:params) do
        super().merge 'server' => 'amqps://user:pwd@server:1234/vhost'
      end

      it do
        is_expected.to include \
          ssl: 0,
          host: 'server',
          user: 'user',
          pass: 'pwd',
          port: 1234,
          vhost: 'vhost',
          scheme: 'amqps'
      end
    end
  end

  describe '#server' do
    subject { config.server }

    it 'defaults to AMQP default on localhost' do
      is_expected.to eq 'amqp://guest@localhost'
    end

    context 'when configured' do
      let(:params) do
        super().merge 'server' => 'amqps://user:pwd@server:1234/vhost'
      end

      it 'strips credentials' do
        is_expected.to eq 'amqps://user@server:1234/vhost'
      end
    end
  end
end
