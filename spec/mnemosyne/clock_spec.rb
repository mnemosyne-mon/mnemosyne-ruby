require 'spec_helper'

describe Mnemosyne::Clock do
  describe '.tick' do
    it 'returns nsec timestamp' do
      Timecop.freeze do
        expect(Mnemosyne::Clock.tick).to eq(Time.now.to_i * 1_000_000_000 + Time.now.nsec)
      end
    end
  end
end
