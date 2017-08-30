# frozen_string_literal: true

require 'rspec'
require 'sidekiq'
require 'sidekiq/testing'

require 'mnemosyne/middleware/sidekiq'

Sidekiq::Testing.server_middleware do |chain|
  chain.add ::Mnemosyne::Middleware::Sidekiq
end

class HardWorker
  include Sidekiq::Worker

  def perform(message)
    # noop
  end
end

RSpec.configure do |config|
  config.before(:each) do
    Sidekiq::Worker.clear_all
    Sidekiq::Testing.fake!
  end
end
