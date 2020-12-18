# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mnemosyne::Global do
  describe '.attach_error' do
    it 'reports exceptions' do
      trace = with_trace do
        raise 'error message'
      rescue RuntimeError => e
        ::Mnemosyne.attach_error(e)
      end

      expect(trace.errors).to be_an Array

      trace.errors.tap do |errors|
        expect(errors.size).to eq 1

        errors.first.tap do |error|
          expect(error.error.class).to eq RuntimeError
          expect(error.error.message).to eq 'error message'
        end
      end
    end
  end
end
