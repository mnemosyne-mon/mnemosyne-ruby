# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mnemosyne::Trace do
  let(:name) { 'trace.test.mnemosyne' }
  let(:kwargs) { {} }
  let(:trace) { ::Mnemosyne::Trace.new(nil, name, kwargs) }

  describe '.serialize' do
    subject { trace.serialize }

    it { is_expected.to be_a Hash }

    describe '[name]' do
      subject { super()[:name] }
      it { is_expected.to eq name }
    end

    describe '[start]' do
      let(:kwargs) { {start: ::Mnemosyne::Clock.to_tick(Time.now)} }

      subject { super()[:start] }
      it { is_expected.to eq kwargs[:start] }
    end

    describe '[stop]' do
      let(:kwargs) { {finish: ::Mnemosyne::Clock.to_tick(Time.now)} }

      subject { super()[:stop] }
      it { is_expected.to eq kwargs[:finish] }
    end

    describe '[uuid]' do
      subject { super()[:uuid] }
      it { is_expected.to eq trace.uuid }
    end

    describe '[meta]' do
      let(:kwargs) { {meta: {a: 1}} }

      subject { super()[:meta] }
      it { is_expected.to eq a: 1 }
    end

    describe '[span]' do
      let(:span) { ::Mnemosyne::Span.new 'span.test.mnemosyne' }

      before do
        trace << span
      end

      subject { super()[:span] }
      it { is_expected.to eq [span.serialize] }
    end

    describe '[errors]' do
      let(:error) do
        begin
          raise 'error'
        rescue RuntimeError => e
          e
        end
      end

      before do
        trace.attach_error(error)
      end

      subject { super()[:errors] }
      it do
        is_expected.to eq [::Mnemosyne::Trace::Error.new(error).serialize]
      end

      context 'with error w/o stacktrace' do
        let(:error) { RuntimeError.new 'error' }

        it { is_expected.to eq [{type: 'RuntimeError', text: 'error'}] }
      end

      context 'with string' do
        let(:error) { 'str' }

        it 'is serialized as a RuntimeError' do
          is_expected.to eq [{type: 'RuntimeError', text: 'str'}]
        end
      end

      context 'with nested errors' do
        let(:error) do
          begin
            begin
              raise 'inner'
            rescue RuntimeError
              raise 'outer'
            end
          rescue RuntimeError => e
            e
          end
        end

        it 'serializes the entire exception hierarchy' do
          is_expected.to match [
            hash_including(
              type: 'RuntimeError',
              text: 'outer',
              cause: hash_including(
                type: 'RuntimeError',
                text: 'inner'
              )
            )
          ]
        end
      end
    end
  end
end
