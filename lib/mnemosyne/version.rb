# frozen_string_literal: true

module Mnemosyne
  module VERSION
    MAJOR = 1
    MINOR = 10
    PATCH = 0
    STAGE = :beta1

    STRING = [MAJOR, MINOR, PATCH, STAGE].reject(&:nil?).join('.')

    def self.to_s
      STRING
    end
  end
end
