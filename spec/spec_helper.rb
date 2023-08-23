# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
$DEBUG = true

require 'mnemosyne'
require 'timecop'

if ENV['DEBUG']
  require 'pry'
  require 'pry-byebug'
end

Mnemosyne::Logging.logger = Logger.new($stdout).tap do |logger|
  logger.level = Logger::DEBUG
end

module VersionHelper
  def version_cmp(version1, comp, version2)
    Gem::Version.new(version1).send(comp, Gem::Version.new(version2))
  end
end

module TracingHelper
  def with_instrumentation(**kwargs, &block)
    traces = []
    client = ->(trace) { traces << trace }
    config = ::Mnemosyne::Configuration.new \
      'application' => kwargs.delete(:application) { 'test' }

    instrumenter = ::Mnemosyne::Instrumenter.new \
      config: config,
      client: client

    ::Mnemosyne::Instrumenter.with(instrumenter, &block)

    traces.first
  end

  def with_trace(name: 'mnemosyne.test', **kwargs, &block)
    with_instrumentation(**kwargs) do |instrumenter|
      instrumenter.trace(name, **kwargs, &block)
    end
  end
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.include VersionHelper
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
