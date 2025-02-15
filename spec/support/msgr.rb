# frozen_string_literal: true

require 'rspec'

require 'rails'
require 'msgr'

class TestConsumer < Msgr::Consumer
  def index
    nil
  end

  def error
    raise 'error'
  end
end
