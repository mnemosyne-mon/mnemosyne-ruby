# frozen_string_literal: true
require 'spec_helper'

describe Mnemosyne::Clock do
  describe '.tick' do
    it 'returns nsec timestamp' do
      Timecop.freeze do
        expect(Mnemosyne::Clock.tick)
          .to eq(Time.now.to_i * 1_000_000_000 + Time.now.nsec)
      end
    end
  end

  describe '.to_tick' do
    it 'returns nsec timestamp' do
      time = Time.now
      expect(Mnemosyne::Clock.to_tick(time))
        .to eq(time.to_i * 1_000_000_000 + time.nsec)
    end
  end
end
