# frozen_string_literal: true

require 'rspec'

require 'active_job'

# When sidekiq is already required before Rails, it won't load
# "sidekiq/rails", which defines the job wrapper required by the AJ
# adapter.
#
# See https://github.com/sidekiq/sidekiq/issues/6612
require 'sidekiq/rails'

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
