# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mnemosyne::Probes do
  it 'injects the loader into Kernel#require' do
    expect(Mnemosyne::Probes).to receive(:required).with('mnemosyne/probes')
    require 'mnemosyne/probes'
  end

  it 'does not make objects respond to require' do
    expect(Object.new).not_to respond_to(:require)
  end
end
