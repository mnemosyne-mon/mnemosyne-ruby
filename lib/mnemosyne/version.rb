# frozen_string_literal: true

module Mnemosyne
  module VERSION
    MAJOR = 2
    MINOR = 1
    PATCH = 1
    STAGE = nil

    STRING = [MAJOR, MINOR, PATCH, STAGE].compact.join('.')

    def self.to_s
      STRING
    end
  end
end
