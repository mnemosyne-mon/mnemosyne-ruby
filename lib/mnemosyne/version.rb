# frozen_string_literal: true

module Mnemosyne
  module VERSION
    MAJOR = 2
    MINOR = 0
    PATCH = 0
    STAGE = nil

    STRING = [MAJOR, MINOR, PATCH, STAGE].compact.join('.')

    def self.to_s
      STRING
    end
  end
end
