# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in mnemosyne.gemspec
gemspec

def vc(name)
  if !(version_constraint = ENV['FARADAY_VERSION'].to_s).empty?
    version_constraint
  end
end

gem 'rake', '~> 12.0'
gem 'rspec', '~> 3.6'
gem 'rubocop', '~> 0.67.1'
gem 'timecop', '~> 0.9.1'

gem 'faraday', vc('FARADAY_VERSION'), require: false
gem 'msgr',    vc('MSGR_VERSION'),    require: false
gem 'restify', vc('RESTIFY_VERSION'), require: false
gem 'sidekiq', vc('SIDEKIQ_VERSION'), require: false

gem 'rails', require: false
gem 'sqlite3', require: false
gem 'webmock', require: false

group :development do
  gem 'appraisal'

  gem 'pry', require: false
  gem 'pry-byebug', require: false
end
