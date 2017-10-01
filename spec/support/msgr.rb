# frozen_string_literal: true

require 'rspec'
require 'msgr'

class TestConsumer < Msgr::Consumer
  def index
    nil
  end

  def error
    raise 'error'
  end
end
