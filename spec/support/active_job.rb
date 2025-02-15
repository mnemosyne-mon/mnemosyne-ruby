# frozen_string_literal: true

require 'rspec'

require 'support/sidekiq'

require 'active_job'

class HardJob < ActiveJob::Base
  queue_as :default

  self.queue_adapter = :sidekiq

  def perform(message)
    # noop
  end
end

class FailJob < ActiveJob::Base
  queue_as :default

  self.queue_adapter = :sidekiq

  def perform(message)
    raise message
  end
end

RSpec.configure do |config|
  include ActiveJob::TestHelper

  config.after(:each) do
    # clear_enqueued_jobs
    # clear_performed_jobs
  end
end
