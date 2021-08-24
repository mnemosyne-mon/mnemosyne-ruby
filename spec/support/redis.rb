# frozen_string_literal: true

require 'rspec'
require 'redis'

RSpec.configure do |c|
  c.before(:suite) do
    redis_pid = fork { exec 'redis-server spec/support/redis.conf' }

    # Wait for the process to have started, otherwise specs may fail
    sleep 1

    at_exit do
      Process.kill('USR1', redis_pid)
    end
  end
end
