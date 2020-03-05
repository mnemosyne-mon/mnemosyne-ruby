# frozen_string_literal: true

require 'rake/release/task'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

task default: %i[rubocop spec]

RuboCop::RakeTask.new(:rubocop) do |task|
  task.fail_on_error = false
end

RSpec::Core::RakeTask.new(:spec)

Rake::Release::Task.new do |spec|
  spec.sign_tag = true
end
