# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'mnemosyne'
require 'timecop'

if ENV['DEBUG']
  require 'pry'
  require 'pry-byebug'
end

class NullClient
  def send(*args); end
end

module TracingHelper
  def with_tracing(name: 'test', **kwargs)
    client = NullClient.new
    logger = ::Logger.new(STDOUT)
    config = ::Mnemosyne::Configuration.new \
      'application' => 'test'

    trace = nil

    instrumenter = ::Mnemosyne::Instrumenter.new \
      config: config,
      logger: logger,
      client: client

    ::Mnemosyne::Instrumenter.with(instrumenter) do |i|
      i.trace(name, **kwargs) do |t|
        trace = t
        yield(t)
      end
    end

    trace
  end
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.include TracingHelper

  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.example_status_persistence_file_path = 'spec/examples.txt'
  config.disable_monkey_patching!
  config.default_formatter = 'doc' if config.files_to_run.one?
  config.profile_examples = 10
  config.order = :random

  Kernel.srand config.seed
end
